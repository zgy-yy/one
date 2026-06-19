import AVKit
import SwiftUI

struct MovieDetailView: View {
    let film: FilmItem

    @State private var player: AVPlayer?

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
            if let coverURL = film.coverURL {
                ImageView(url: coverURL)
            } else {
                Rectangle()
                    .fill(.quaternary)
            }
            FilmStripEdge(stripHeight: 18, holeSize: 10, filmColor: Color.black.opacity(0.5))
        }
        .frame(height: 260)
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
        if let player {
            AVPlayerView(player: player)
                .aspectRatio(16 / 9, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else if film.playURL != nil {
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
        guard let url = film.playURL else { return }
        let player = AVPlayer(url: url)
        self.player = player
        player.play()
    }

    private func stopPlayback() {
        player?.pause()
        player = nil
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(film: .preview)
    }
}
