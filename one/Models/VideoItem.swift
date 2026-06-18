import Foundation

struct VideoItem: Identifiable, Sendable {
    let id: Int
    let title: String
    let img: String
    let video: String?

    var coverURL: URL? { URL(string: img) }

    var playURL: URL? {
        if let video, let url = URL(string: video) {
            return url
        }
        let samples = Self.samplePlayURLs
        guard !samples.isEmpty else { return nil }
        return URL(string: samples[(id - 1) % samples.count])
    }

    private static let samplePlayURLs = [
        "https://sf1-cdn-tos.huoshanstatic.com/obj/media-fe/xgplayer_doc_video/hls/xgplayer-demo.m3u8",
        "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8",
        "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8",
    ]
}

extension VideoItem: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id, title, img, video
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        img = try container.decode(String.self, forKey: .img)
        video = try container.decodeIfPresent(String.self, forKey: .video)
    }
}
