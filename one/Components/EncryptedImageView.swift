import SwiftUI

struct EncryptedImageView: View {
    let url: URL

    @State private var image: UIImage?
    @State private var failed = false

    init(url: URL) {
        self.url = url
        _image = State(initialValue: ImageCache.image(for: url))
        _failed = State(initialValue: false)
    }

    var body: some View {
        Group {
            if let image {
                AnimatedImageView(image: image)
            } else if failed {
                placeholder
            } else {
                placeholder
                    .overlay { ProgressView() }
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(.quaternary)
    }

    private func loadImage() async {
        if image != nil { return }

        if let cached = ImageCache.image(for: url) {
            image = cached
            return
        }

        failed = false

        do {
            image = try await APICrypto.loadDecryptedImage(from: url)
        } catch {
            failed = true
        }
    }
}
