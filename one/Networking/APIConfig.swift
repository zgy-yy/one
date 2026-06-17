import Foundation

enum APIConfig: Sendable {
    nonisolated static let baseURL = URL(string: "http://localhost:3000")!
    nonisolated static let appVersion = "2.6.3.1"
}
