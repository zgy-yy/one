import KSPlayer
import SwiftUI

struct MoviePlayer: View {
    let url: URL
    let title: String

    @StateObject private var coordinator = KSVideoPlayer.Coordinator()
    @State private var options = KSOptions()

    var body: some View {
        KSVideoPlayerView(coordinator: coordinator, url: url, options: options, title: title)
            .background(.black)
    }
}
