import Foundation

enum APIError: Error, LocalizedError {
    case badResponse
    case badStatus(Int)

    var errorDescription: String? {
        switch self {
        case .badResponse: "Bad response"
        case .badStatus(let code): "HTTP \(code)"
        }
    }
}

protocol APIClient: Sendable {
    func data(from url: URL) async throws -> Data
}

struct URLSessionAPIClient: APIClient {
    var session: URLSession = .shared

    func data(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse else { throw APIError.badResponse }
        guard (200..<300).contains(http.statusCode) else { throw APIError.badStatus(http.statusCode) }
        return data
    }
}
