import AVKit
import SwiftUI

struct MovieDetailView: View {
    let video: VideoItem

    @State private var player: AVPlayer?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                playerSection
                Text(video.title)
                    .font(.title2.bold())
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: startPlayback)
        .onDisappear(perform: stopPlayback)
    }

    @ViewBuilder
    private var playerSection: some View {
        if let player {
            VideoPlayer(player: player)
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else if video.playURL != nil {
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary)
                .aspectRatio(16 / 9, contentMode: .fit)
                .overlay { ProgressView() }
        } else {
            ContentUnavailableView(
                "无法播放",
                systemImage: "play.slash",
                description: Text("暂无可用视频地址")
            )
            .frame(maxWidth: .infinity)
            .aspectRatio(16 / 9, contentMode: .fit)
        }
    }

    private func startPlayback() {
        guard let url = video.playURL else { return }
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
