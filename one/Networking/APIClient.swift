import Foundation

private struct APIEnvelope<U: Decodable>: Decodable {
    let data: U?
}

protocol APIRequesting: Sendable {
    func get<T: Decodable & Sendable>(_ type: T.Type, path: String) async throws -> T
    func post<T: Decodable & Sendable>(_ type: T.Type, path: String, body: [String: String])
        async throws -> T
}

struct APIClient: APIRequesting, Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let auth: APIAuthContext

    nonisolated init(
        baseURL: URL = APIConfig.baseURL,
        session: URLSession = .shared,
        decoder: JSONDecoder = APIClient.makeDecoder(),
        auth: APIAuthContext = APIConfig.auth
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.auth = auth
    }

    func get<T: Decodable & Sendable>(_ type: T.Type, path: String) async throws -> T {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "GET"

        for (key, value) in auth.signedHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            throw APIError.invalidResponse
        }

        return try decoder.decode(T.self, from: data)
    }

    func post<T: Decodable & Sendable>(
        _ type: T.Type, path: String, body: [String: String]
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        let encrypted = try APICrypto.aesEncrypt(toFormBody(body))
        request.httpBody = Data(encrypted.utf8)

        for (key, value) in auth.signedHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpStatus(httpResponse.statusCode)
        }
        guard let responseText = String(data: data, encoding: .utf8), !responseText.isEmpty else {
            throw APIError.invalidResponse
        }

        let decrypted = try APICrypto.aesDecrypt(responseText)
        let json = Data(decrypted.utf8)

        if let envelope = try? decoder.decode(APIEnvelope<T>.self, from: json),
            let value = envelope.data
        {
            return value
        }

        return try decoder.decode(T.self, from: json)
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

func toFormBody(_ data: [String: String]) -> String {
    var components = URLComponents()
    components.queryItems = data.map { URLQueryItem(name: $0.key, value: $0.value) }
    return components.percentEncodedQuery ?? ""
}

enum APIError: Error, Sendable {
    case invalidResponse
    case httpStatus(Int)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "服务器响应异常"
        case .httpStatus(let code):
            "服务器响应异常（HTTP \(code)）"
        }
    }
}
