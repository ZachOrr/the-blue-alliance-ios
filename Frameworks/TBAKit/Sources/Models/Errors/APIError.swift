import Foundation

public enum APIError: Error {
    case invalidURL
    case invalidHTTPResponse
    case invalidResponse(Error)
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidHTTPResponse:
            return "Invalid HTTP response"
        case .invalidResponse(let error):
            return "Invalid response - \(error.localizedDescription)"
        }
    }
}
