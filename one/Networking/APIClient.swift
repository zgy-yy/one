import Foundation

protocol APIRequesting: Sendable {
    func get<T: Decodable & Sendable>(_ type: T.Type, path: String) async throws -> T
}

struct APIClient: APIRequesting, Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    nonisolated init(
        baseURL: URL = APIConfig.baseURL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    nonisolated func get<T: Decodable & Sendable>(_ type: T.Type, path: String) async throws -> T {
        let url = baseURL.appending(path: path)
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200 ... 299).contains(httpResponse.statusCode)
        else {
            throw APIError.invalidResponse
        }

        return try decoder.decode(T.self, from: data)
    }
}

enum APIError: Error, Sendable {
    case invalidResponse
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "服务器响应异常"
        }
    }
}
