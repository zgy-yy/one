import Foundation
import Observation

@Observable
@MainActor
final class FilmViewModel {
    private(set) var films: [FilmItem] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let service: any DiscoveryServicing

    init(service: any DiscoveryServicing = DiscoveryService()) {
        self.service = service
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            films = try await service.fetchFilmList()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
