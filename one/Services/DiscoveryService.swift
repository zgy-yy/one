import Foundation

protocol DiscoveryServicing: Sendable {
    func fetchFilmList() async throws -> [VideoItem]
}

struct DiscoveryService: DiscoveryServicing, Sendable {
    private let api: APIRequesting

    nonisolated init(api: APIRequesting = APIClient()) {
        self.api = api
    }

    nonisolated func fetchFilmList() async throws -> [VideoItem] {
        try await api.get([VideoItem].self, path: "list")
    }
}
