import SwiftUI

struct ImageView: View {
    let url: URL
    let maxPixelSize: Int?

    @State private var image: UIImage?
    @State private var failed = false

    init(url: URL, maxPixelSize: Int? = nil) {
        self.url = url
        self.maxPixelSize = maxPixelSize
        _image = State(initialValue: ImageCache.image(for: url, maxPixelSize: maxPixelSize))
        _failed = State(initialValue: false)
    }

    var body: some View {
        Group {
            if let image {
                imageContent(image)
            } else if failed {
                placeholder
            } else {
                placeholder
            }
        }
        .task(id: taskID) {
            await loadImage()
        }
    }

    private var taskID: String {
        if let maxPixelSize {
            "\(url.absoluteString)#\(maxPixelSize)"
        } else {
            url.absoluteString
        }
    }

    @ViewBuilder
    private func imageContent(_ image: UIImage) -> some View {
        if image.isAnimatedGIF {
            AnimatedImageView(image: image)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(.quaternary)
    }

    private func loadImage() async {
        if image != nil { return }

        if let cached = ImageCache.image(for: url, maxPixelSize: maxPixelSize) {
            image = cached
            return
        }

        failed = false

        do {
            image = try await APIClient.loadImage(
                from: url,
                maxPixelSize: maxPixelSize
            )
        } catch is CancellationError {
            return
        } catch {
            failed = true
        }
    }
}
