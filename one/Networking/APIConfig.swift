import Foundation

enum APIConfig: Sendable {
    nonisolated static let baseURL = URL(string: "http://localhost:3000")!
}
