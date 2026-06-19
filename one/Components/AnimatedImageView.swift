import ImageIO
import SwiftUI
import UIKit

enum GIFImage {
    static func makeImage(from data: Data, maxPixelSize: Int? = nil) -> UIImage? {
        guard isGIF(data) else {
            return stillImage(from: data, maxPixelSize: maxPixelSize)
        }
        return animatedImage(from: data, maxPixelSize: maxPixelSize)
    }

    private static func isGIF(_ data: Data) -> Bool {
        data.starts(with: [0x47, 0x49, 0x46])
    }

    private static func stillImage(from data: Data, maxPixelSize: Int?) -> UIImage? {
        guard let maxPixelSize else {
            return UIImage(data: data)
        }
        guard
            let source = CGImageSourceCreateWithData(data as CFData, nil),
            let cgImage = cgImage(at: 0, in: source, maxPixelSize: maxPixelSize)
        else {
            return UIImage(data: data)
        }
        return UIImage(cgImage: cgImage)
    }

    private static func animatedImage(from data: Data, maxPixelSize: Int?) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let frameCount = CGImageSourceGetCount(source)
        guard frameCount > 1 else {
            return stillImage(from: data, maxPixelSize: maxPixelSize)
        }

        var images: [UIImage] = []
        var duration: TimeInterval = 0

        for index in 0..<frameCount {
            guard let cgImage = cgImage(at: index, in: source, maxPixelSize: maxPixelSize) else {
                continue
            }
            images.append(UIImage(cgImage: cgImage))
            duration += frameDuration(at: index, in: source)
        }

        guard !images.isEmpty else { return nil }
        return UIImage.animatedImage(with: images, duration: max(duration, 0.1))
    }

    private static func cgImage(
        at index: Int,
        in source: CGImageSource,
        maxPixelSize: Int?
    ) -> CGImage? {
        if let maxPixelSize {
            return CGImageSourceCreateThumbnailAtIndex(
                source,
                index,
                thumbnailOptions(maxPixelSize: maxPixelSize) as CFDictionary
            )
        }
        return CGImageSourceCreateImageAtIndex(source, index, nil)
    }

    private static func thumbnailOptions(maxPixelSize: Int) -> [CFString: Any] {
        [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceCreateThumbnailWithTransform: true,
        ]
    }

    private static func frameDuration(at index: Int, in source: CGImageSource) -> TimeInterval {
        guard
            let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
                as? [CFString: Any],
            let gifInfo = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any]
        else {
            return 0.1
        }

        let unclamped = gifInfo[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval
        let clamped = gifInfo[kCGImagePropertyGIFDelayTime] as? TimeInterval
        let delay = unclamped ?? clamped ?? 0.1
        return delay > 0.011 ? delay : 0.1
    }
}

extension UIImage {
    var isAnimatedGIF: Bool {
        (images?.count ?? 0) > 1
    }
}

struct AnimatedImageView: UIViewRepresentable {
    let image: UIImage

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return imageView
    }

    func updateUIView(_ imageView: UIImageView, context: Context) {
        imageView.image = image
    }
}
