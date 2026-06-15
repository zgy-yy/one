import Foundation

struct VideoItem: Identifiable, Sendable {
    let id: Int
    let title: String
    let img: String

    nonisolated var coverURL: URL? { URL(string: img) }
}

extension VideoItem: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id, title, img
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        img = try container.decode(String.self, forKey: .img)
    }
}
