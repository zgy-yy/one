import Foundation

protocol DiscoveryServicing: Sendable {
    func fetchFilmList() async throws -> [FilmItem]
}

struct DiscoveryService: DiscoveryServicing, Sendable {
    private let api: APIRequesting

    init(api: APIRequesting = APIClient()) {
        self.api = api
    }

    func fetchFilmList() async throws -> [FilmItem] {
        let body = [
            "published_at": Self.publishedDate(),
            "model_id": "3",
            "size": "31",
            "page": "1",
            "sort": "published_at",
        ]

        return try await api.post(
            [FilmItem].self,
            path: "/v2.5/article/discovery",
            body: body
        )
    }

    private static let publishedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()

    private static func publishedDate() -> String {
        publishedDateFormatter.string(from: Date())
    }
}
