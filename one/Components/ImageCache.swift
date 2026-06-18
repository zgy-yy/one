import UIKit

enum ImageCache {
    private static let storage: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 300
        cache.totalCostLimit = 150 * 1024 * 1024
        return cache
    }()

    nonisolated static func image(for url: URL) -> UIImage? {
        storage.object(forKey: url as NSURL)
    }

    nonisolated static func store(_ image: UIImage, for url: URL) {
        storage.setObject(image, forKey: url as NSURL)
    }

    static func load(
        from url: URL,
        loader: @escaping @Sendable () async throws -> UIImage
    ) async throws -> UIImage {
        try await ImageCacheCoordinator.shared.load(from: url, loader: loader)
    }
}

private actor ImageCacheCoordinator {
    static let shared = ImageCacheCoordinator()

    private var inflight = [URL: Task<UIImage, Error>]()

    func load(
        from url: URL,
        loader: @escaping @Sendable () async throws -> UIImage
    ) async throws -> UIImage {
        if let cached = ImageCache.image(for: url) {
            return cached
        }

        if let existing = inflight[url] {
            return try await existing.value
        }

        let task = Task { try await loader() }
        inflight[url] = task
        defer { inflight[url] = nil }

        let image = try await task.value
        ImageCache.store(image, for: url)
        return image
    }
}
