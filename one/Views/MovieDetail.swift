import SDWebImageSwiftUI
import SwiftUI

struct MovieDetailView: View {
    let film: FilmItem

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
        .background(Color(uiColor: .systemBackground))
        .toolbar(.visible, for: .navigationBar)
        .ignoresSafeArea(.container, edges: [.top, .bottom])
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
            MoviePlayer(url: playURL, title: film.resolvedTitle)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityLabel(Text(playURL.lastPathComponent))
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
