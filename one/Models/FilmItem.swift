import Foundation

struct FilmItem: Identifiable, Sendable, Decodable {
    let id: Int
    let audioFile: String?
    let audioHls: String?
    let author: String?
    let buy: Int?
    let collectionNumber: Int?
    let demandActivity: [String: String]?
    let description: String?
    let downloadCount: Int?
    let haveCollection: Int?
    let isCollected: Int?
    let isDecode: Int?
    let isLike: Int?
    let isLimitFree: Int?
    let isSubtitle: Int?
    let likeNumber: Int?
    let modelId: Int?
    let noVipDownloadCoin: String?
    let onlyVipDownload: String?
    let pid: Int?
    let previewVideo: String?
    let publishedAt: String?
    let replyCounts: Int?
    let seriesCategory: Int?
    let sort: Int?
    let tags: [String]?
    let thumb: String?
    let thumbnail: String?
    let title: String?
    let video: String?
    let videoCover: String?
    let videoFile: String?
    let videoHls: String?
    let videoHlsH265: String?
    let videoLength: String?
    let videoName: String?
    let views: Int?
    let vol: Int?

    var resolvedTitle: String {
        let text = title ?? videoName ?? description ?? ""
        return text.isEmpty ? "未命名" : text
    }

    var resolvedTags: [String] { tags ?? [] }

    var thumbURL: URL? {
        Self.imageURL(thumb)
    }

    var thumbnailURL: URL? {
        Self.imageURL(thumbnail)
    }

    var coverURL: URL? {
        thumbURL ?? thumbnailURL
    }

    var displayLength: String? {
        guard let videoLength, !videoLength.isEmpty else { return nil }
        return videoLength
    }

    var playURL: URL? {
        Self.mediaURL(video)
            ?? Self.mediaURL(videoFile)
            ?? Self.mediaURL(videoHls)
            ?? Self.mediaURL(videoHlsH265)
            ?? Self.mediaURL(previewVideo)
    }

    static func imageURL(_ path: String?) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        if path.hasPrefix("http") {
            return URL(string: path)
        }
        return URL(string: path, relativeTo: APIConfig.imageURL)?.absoluteURL
    }

    static func mediaURL(_ path: String?) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        if path.hasPrefix("http") {
            return URL(string: path)
        }
        return URL(string: path, relativeTo: APIConfig.mediaURL)?.absoluteURL
    }
}

extension FilmItem {
    static let preview = FilmItem(
        id: 52960,
        audioFile: "",
        audioHls: "",
        author: "comatozze",
        buy: 0,
        collectionNumber: 15800,
        demandActivity: [:],
        description: "P站顶流巨乳毛妹「Comatozze」十八岁巨乳骚货P站近期新作合集🔥",
        downloadCount: 4300,
        haveCollection: 0,
        isCollected: 0,
        isDecode: 0,
        isLike: 0,
        isLimitFree: 0,
        isSubtitle: 0,
        likeNumber: 8261,
        modelId: 3,
        noVipDownloadCoin: nil,
        onlyVipDownload: "0",
        pid: 0,
        previewVideo: "",
        publishedAt: "2026-06-18 00:00:00",
        replyCounts: 126,
        seriesCategory: 0,
        sort: 5,
        tags: ["comatozze", "欧美", "反差", "金发", "巨乳", "白虎"],
        thumb: "/storage/thumb/52960/6a32c7172fd47.gif",
        thumbnail: "/storage/thumb/52960/6a32c7172fd47_thumbnail.gif",
        title: "P站顶流巨乳毛妹「Comatozze」十八岁巨乳骚货P站近期新作合集🔥",
        video:
            "/one/compress/decry/vd/20260618/Y2IxNThjNTk5OG/000235/1920_1080/aac/h265/mp4/decrypt/mJlN.mp4",
        videoCover: "",
        videoFile:
            "/one/compress/decry/vd/20260618/Y2IxNThjNTk5OG/000235/1920_1080/aac/h265/mp4/decrypt/mJlN.mp4",
        videoHls:
            "/encry/vd/20260618/ZDI1ZDJmMzJlNz/000235/1920_1080/aac/h264/hls/decrypt/index.m3u8",
        videoHlsH265:
            "/encry/vd/20260618/Y2IxNThjNTk5OG/000235/1920_1080/aac/h265/hls/decrypt/index.m3u8",
        videoLength: "",
        videoName: "P站顶流巨乳毛妹「Comatozze」十八岁巨乳骚货P站近期新作合集🔥",
        views: 167847,
        vol: 2415
    )
}
