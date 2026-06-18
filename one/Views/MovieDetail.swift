import AVKit
import SwiftUI

struct MovieDetailView: View {
    let video: VideoItem

    @State private var player: AVPlayer?
    let tagsList = [
        "标签1", "标签2", "标签3", "动作", "科幻", "悬疑", "高清", "爱情", "喜剧", "动作", "科幻", "悬疑", "高清", "爱情", "喜剧",
    ]

    var body: some View {
        ScrollView {
            topBg
            VStack(alignment: .leading, spacing: 16) {
                playerSection
                title
                tags
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: startPlayback)
        .onDisappear(perform: stopPlayback)
        .ignoresSafeArea(.container, edges: .top)
    }

    //顶部背景
    var topBg: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.red)

            FilmStripEdge(stripHeight: 18, holeSize: 10, filmColor: Color.black.opacity(0.6))
        }
        .frame(height: 220)
    }

    //标题
    var title: some View {
        Text(video.title)
            .font(.title2.bold())
            .foregroundStyle(.primary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
    //标签
    var tags: some View {
        FlowLayout(spacing: 8, rowSpacing: 8) {
            ForEach(tagsList, id: \.self) { tag in
                Tag(title: tag)
            }
        }
    }

    //播放器
    @ViewBuilder
    private var playerSection: some View {
        if let player {
            AVPlayerView(player: player)
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else if video.playURL != nil {
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary)
                .aspectRatio(16 / 9, contentMode: .fill)
                .overlay { ProgressView() }
        } else {
            ContentUnavailableView(
                "无法播放",
                systemImage: "play.slash",
                description: Text("暂无可用视频地址")
            )
            .frame(maxWidth: .infinity)
            .aspectRatio(16 / 9, contentMode: .fill)
        }
    }

    private func startPlayback() {
        guard let url = video.playURL else { return }
        let player = AVPlayer(url: url)
        self.player = player
        //        player.play()
    }

    private func stopPlayback() {
        player?.pause()
        player = nil
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(
            video: VideoItem(
                id: 1,
                title: "示例视频",
                img: "https://picsum.photos/400/225",
                video:
                    "https://sf1-cdn-tos.huoshanstatic.com/obj/media-fe/xgplayer_doc_video/hls/xgplayer-demo.m3u8"
            )
        )
    }
}
