import Foundation

protocol APIRequesting: Sendable {
    func get<T: Decodable & Sendable>(_ type: T.Type, path: String) async throws -> T
}

struct APIClient: APIRequesting, Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let auth: APIAuthContext?

    nonisolated init(
        baseURL: URL = APIConfig.baseURL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        auth: APIAuthContext? = nil
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.auth = auth
    }

    nonisolated func get<T: Decodable & Sendable>(_ type: T.Type, path: String) async throws -> T {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "GET"

        if let auth {
            for (key, value) in auth.signedHeaders() {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        let (data, response) = try await session.data(for: request)

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
