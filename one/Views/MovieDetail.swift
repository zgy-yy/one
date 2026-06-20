import SDWebImageSwiftUI
import SwiftUI

struct MovieDetailView: View {
    let film: FilmItem

    @State private var isFullScreen = false

    var body: some View {
        // 小窗：VStack 滚动内容 + 底部播放器；全屏：ZStack 播放器覆盖全屏
        let layout =
            isFullScreen
            ? AnyLayout(ZStackLayout())
            : AnyLayout(VStackLayout(spacing: 0))

        ScrollView {
            layout {
                topBg
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        if let vol = film.vol {
                            Text("第 \(vol) 期")
                        }
                        Spacer()
                        Text(film.publishedAt?.resolvedPublishedDate ?? "")
                    }
                    title
                    HStack {
                        Text("出品 / " + (film.author ?? ""))
                        Spacer()
                        Image(systemName: "film.stack.fill")
                            .font(.title3)
                    }
                    tags
                }
                .padding()
                playerSection

            }
        }
        .background(Color(uiColor: .systemBackground))
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(isFullScreen)
        .ignoresSafeArea(isFullScreen ? .all : .container, edges: [.top, .bottom])
    }

    //顶部背景
    var topBg: some View {
        ZStack(alignment: .bottom) {
            if let coverURL = film.coverURL {
                GeometryReader { proxy in
                    WebImage(url: coverURL)
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.2))
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                }
            } else {
                Rectangle()
                    .fill(.quaternary)
            }
            FilmStripEdge(stripHeight: 18, holeSize: 10, filmColor: Color.black.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .clipped()
    }

    //标题
    var title: some View {
        Text(film.resolvedTitle)
            .font(.title2.bold())
            .foregroundStyle(.primary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }

    //标签
    var tags: some View {
        FlowLayout(spacing: 8, rowSpacing: 8) {
            ForEach(film.resolvedTags, id: \.self) { tag in
                Tag(title: tag)
            }
        }
    }

    //播放器
    @ViewBuilder
    private var playerSection: some View {
        if let playURL = film.playURL {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let fullWidth = scene.screen.bounds.width
                let fullHeight = scene.screen.bounds.height
                MoviePlayer(url: playURL, title: film.resolvedTitle, isFullScreen: $isFullScreen)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(
                        width: isFullScreen ? fullWidth : nil,
                        height: isFullScreen ? fullHeight : nil
                    )
                    .ignoresSafeArea(.container, edges: [.top, .bottom])
                    .aspectRatio(isFullScreen ? nil : 16 / 9, contentMode: .fit)
                    .padding(isFullScreen ? 0 : 16)
            }

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
}

#Preview {
    NavigationStack {
        MovieDetailView(film: .preview)
    }
}
