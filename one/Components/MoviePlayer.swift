import KSPlayer
import SwiftUI

/// 基于 KSPlayer 的视频播放器，支持小窗 16:9 播放与横屏全屏。
struct MoviePlayer: View {
    let url: URL
    let title: String

    /// 播放器协调器，统一管理 KSVideoPlayer 的播放、seek、暂停等操作
    @StateObject private var coordinator = KSVideoPlayer.Coordinator()
    @State private var options = KSOptions()
    /// 同步 KSPlayer 内部状态，用于控制 loading 图标和播放/暂停按钮
    @State private var state: KSPlayerState = .initialized
    @State private var currentTime: TimeInterval = 0
    @State private var totalTime: TimeInterval = 1
    @State private var isControlsVisible = true
    /// 拖动进度条时为 true，此时忽略 onPlay 回调，避免滑块跳动
    @State private var isSeeking = false
    @State private var seekingTime: TimeInterval = 0
    @State private var isFullScreen = false

    var body: some View {
        GeometryReader { geometry in
            playerSurface(size: geometry.size)
        }
        // 全屏时忽略安全区域，隐藏状态栏和 Home 指示条
        .ignoresSafeArea(isFullScreen ? .all : .keyboard)
        .statusBarHidden(isFullScreen)
        .persistentSystemOverlays(isFullScreen ? .hidden : .automatic)
    }

    private func playerSurface(size: CGSize) -> some View {
        ZStack {
            Color.black

            KSVideoPlayer(coordinator: coordinator, url: url, options: options)
                .onStateChanged { _, newState in
                    state = newState
                }
                .onPlay { current, total in
                    // 拖动进度条期间不更新 currentTime，由 seekingTime 接管
                    guard !isSeeking else { return }
                    currentTime = current
                    totalTime = max(total, 1)
                }

            if isLoading {
                ProgressView()
                    .tint(.white)
                    .controlSize(.large)
            }

            if isControlsVisible {
                controls
                    .transition(.opacity)
            }
        }
        /*
         全屏横屏布局（不依赖 UIKit 转屏）：
         1. 先把 frame 宽高对调，让内容在竖屏坐标系里按「横屏比例」排版
         2. rotationEffect(90°) 顺时针旋转，视觉上变为横屏
         3. 外层 frame 重新对齐到屏幕尺寸，居中显示
         小窗模式：宽度撑满，高度按 16:9 自适应
         */
        .frame(
            width: isFullScreen ? size.height : size.width,
            height: isFullScreen ? size.width : nil
        )
        .aspectRatio(isFullScreen ? nil : 16 / 9, contentMode: .fit)
        .rotationEffect(isFullScreen ? .degrees(90) : .degrees(0))
        .frame(width: size.width, height: size.height)
        // 让整个矩形区域（含透明部分）都可点击，用于切换控制栏显隐
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isControlsVisible.toggle()
            }
        }
    }

    private var controls: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .foregroundStyle(.white)

                Spacer()
            }
            // 全屏旋转后，左右边缘对应原屏幕的上下，需加大 padding 避开刘海/灵动岛
            .padding(.horizontal, isFullScreen ? 44 : 14)
            .padding(.top, isFullScreen ? 24 : 12)
            .padding(.bottom, 28)
            .background(
                LinearGradient(
                    colors: [.black.opacity(0.65), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            Spacer()

            // 底部控制栏：进度条 + 播放控制
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    Text(timeText(isSeeking ? seekingTime : currentTime))
                    Slider(
                        value: Binding {
                            isSeeking ? seekingTime : currentTime
                        } set: { newValue in
                            seekingTime = newValue
                        },
                        in: 0 ... max(totalTime, 1),
                        onEditingChanged: { editing in
                            isSeeking = editing
                            if editing {
                                // 开始拖动：记录当前位置作为起点
                                seekingTime = currentTime
                            } else {
                                // 松手：提交 seek 并恢复播放进度同步
                                currentTime = seekingTime
                                coordinator.seek(time: seekingTime)
                            }
                        }
                    )
                    Text(timeText(totalTime))
                }
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.white)

                HStack(spacing: 14) {
                    controlButton(systemName: "gobackward.15") {
                        skip(seconds: -15)
                    }

                    controlButton(
                        systemName: state.isPlaying ? "pause.fill" : "play.fill",
                        action: togglePlayback
                    )

                    controlButton(systemName: "goforward.15") {
                        skip(seconds: 15)
                    }

                    Spacer()

                    controlButton(
                        systemName: isFullScreen
                            ? "arrow.down.right.and.arrow.up.left"
                            : "arrow.up.left.and.arrow.down.right"
                    ) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isFullScreen.toggle()
                            isControlsVisible = true
                        }
                    }
                }
            }
            .padding(.horizontal, isFullScreen ? 44 : 14)
            .padding(.bottom, isFullScreen ? 20 : 12)
            .padding(.top, 12)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }

    private var isLoading: Bool {
        state == .initialized || state == .preparing || state == .buffering
    }

    private func togglePlayback() {
        if state.isPlaying {
            coordinator.playerLayer?.pause()
        } else {
            coordinator.playerLayer?.play()
        }
    }

    private func skip(seconds: Int) {
        coordinator.skip(interval: seconds)
        // 立即更新 UI，避免等待 onPlay 回调产生延迟感
        currentTime = min(max(currentTime + TimeInterval(seconds), 0), totalTime)
    }

    /// - Parameter action: `@escaping` 表示闭包会被 Button 保存，在用户点击后才执行，而非调用时立刻执行
    private func controlButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(.black.opacity(0.45), in: Circle())
        }
        .buttonStyle(.plain)
    }

    private func timeText(_ time: TimeInterval) -> String {
        let totalSeconds = max(Int(time), 0)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
}

#Preview {
    MoviePlayer(
        url: URL(
            string:
                "https://dlmk.bx7qxb.com/one/compress/decry/vd/20260607/MmI0ZDgwMGUyZ/203216/1920_1080/aac/h265/mp4/decrypt/GFkM.mp4"
        )!,
        title: "Rick Astley - Never Gonna Give You Up"
    )
}
