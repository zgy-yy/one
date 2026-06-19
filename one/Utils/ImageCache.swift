import UIKit

enum ImageCache {
    private static let storage: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 300
        cache.totalCostLimit = 300 * 1024 * 1024
        return cache
    }()

    static func key(for url: URL, maxPixelSize: Int?) -> NSString {
        if let maxPixelSize {
            return "\(url.absoluteString)#\(maxPixelSize)" as NSString
        }
        return url.absoluteString as NSString
    }

    static func image(for url: URL, maxPixelSize: Int? = nil) -> UIImage? {
        storage.object(forKey: key(for: url, maxPixelSize: maxPixelSize))
    }

    static func store(_ image: UIImage, for url: URL, maxPixelSize: Int? = nil) {
        storage.setObject(
            image,
            forKey: key(for: url, maxPixelSize: maxPixelSize),
            cost: memoryCost(of: image)
        )
    }

    static func load(
        from url: URL,
        maxPixelSize: Int? = nil,
        loader: @escaping @Sendable () async throws -> UIImage
    ) async throws -> UIImage {
        try await ImageCacheCoordinator.shared.load(
            from: url,
            maxPixelSize: maxPixelSize,
            loader: loader
        )
    }

    private static func memoryCost(of image: UIImage) -> Int {
        if let images = image.images, !images.isEmpty {
            return images.reduce(0) { partial, frame in
                partial + frameCost(frame)
            }
        }
        return frameCost(image)
    }

    private static func frameCost(_ image: UIImage) -> Int {
        Int(image.size.width * image.size.height * image.scale * image.scale * 4)
    }
}

private actor ImageCacheCoordinator {
    static let shared = ImageCacheCoordinator()

    private static let maxConcurrentLoads = 5

    private var inflight = [NSString: Task<UIImage, Error>]()
    private var activeLoads = 0
    private var loadWaiters: [CheckedContinuation<Void, Never>] = []

    func load(
        from url: URL,
        maxPixelSize: Int?,
        loader: @escaping @Sendable () async throws -> UIImage
    ) async throws -> UIImage {
        let cacheKey = ImageCache.key(for: url, maxPixelSize: maxPixelSize)

        if let cached = ImageCache.image(for: url, maxPixelSize: maxPixelSize) {
            return cached
        }

        if let existing = inflight[cacheKey] {
            return try await existing.value
        }

        let task = Task(priority: .utility) {
            try await self.performLoad(
                url: url,
                maxPixelSize: maxPixelSize,
                loader: loader
            )
        }
        inflight[cacheKey] = task
        defer { inflight[cacheKey] = nil }

        return try await task.value
    }

    private func performLoad(
        url: URL,
        maxPixelSize: Int?,
        loader: @escaping @Sendable () async throws -> UIImage
    ) async throws -> UIImage {
        await waitForSlot()
        defer { releaseSlot() }

        if let cached = ImageCache.image(for: url, maxPixelSize: maxPixelSize) {
            return cached
        }

        let image = try await loader()
        ImageCache.store(image, for: url, maxPixelSize: maxPixelSize)
        return image
    }

    private func waitForSlot() async {
        if activeLoads < Self.maxConcurrentLoads {
            activeLoads += 1
            return
        }

        await withCheckedContinuation { continuation in
            loadWaiters.append(continuation)
        }
        activeLoads += 1
    }

    private func releaseSlot() {
        activeLoads -= 1
        if !loadWaiters.isEmpty {
            loadWaiters.removeFirst().resume()
        }
    }
}
