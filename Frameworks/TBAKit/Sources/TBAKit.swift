import Combine
import Foundation

public typealias TBAKitOperationCompletion = (_ response: HTTPURLResponse?, _ json: Any?, _ error: Error?) -> ()

private struct Constants {
    struct APIConstants {
        static let baseURL = URL(string: "https://www.thebluealliance.com/api/v3/")!
        static let lastModifiedDictionary = "LastModifiedDictionary"
        static let etagDictionary = "EtagDictionary"
    }
}

public enum APIError: Error {
    case error(String)
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error(message: let message):
            // TODO: This, unlike the name says, isn't localized
            return message
        }
    }
}

internal protocol TBAModel {
    init?(json: [String: Any])
}

open class TBAKit: NSObject {

    internal let apiKey: String
    internal let urlSession: URLSession
    internal let userDefaults: UserDefaults

    public init(apiKey: String, urlSession: URLSession? = nil, userDefaults: UserDefaults) {
        self.apiKey = apiKey
        self.urlSession = urlSession ?? URLSession(configuration: .default)
        self.userDefaults = userDefaults
    }

    public func storeCacheHeaders(_ response: URLResponse) {
        // Pull our response off of our request
        guard let httpResponse = response as? HTTPURLResponse else {
            return
        }
        // Grab our lastModified to store
        let lastModified = httpResponse.allHeaderFields["Last-Modified"]
        // Grab our etag to store
        let etag = httpResponse.allHeaderFields["Etag"]

        // And finally, grab our URL
        guard let url = httpResponse.url else {
            return
        }

        if let lastModified = lastModified as? String {
            let lastModifiedString = TBAKit.lastModifiedURLString(for: url)
            var lastModifiedDictionary = userDefaults.dictionary(forKey: Constants.APIConstants.lastModifiedDictionary) ?? [:]
            lastModifiedDictionary[lastModifiedString] = lastModified
            userDefaults.set(lastModifiedDictionary, forKey: Constants.APIConstants.lastModifiedDictionary)
        }
        if let etag = etag as? String {
            let etagString = TBAKit.etagURLString(for: url)
            var etagDictionary = userDefaults.dictionary(forKey: Constants.APIConstants.etagDictionary) ?? [:]
            etagDictionary[etagString] = etag
            userDefaults.set(etagDictionary, forKey: Constants.APIConstants.etagDictionary)
        }
        userDefaults.synchronize()
    }

    public func clearCacheHeaders() {
        userDefaults.removeObject(forKey: Constants.APIConstants.lastModifiedDictionary)
        userDefaults.removeObject(forKey: Constants.APIConstants.etagDictionary)
        userDefaults.synchronize()
    }

    static func lastModifiedURLString(for url: URL) -> String {
        return "LAST_MODIFIED:\(url.absoluteString)"
    }

    static func etagURLString(for url: URL) -> String {
        return "ETAG:\(url.absoluteString)"
    }

    func lastModified(for url: URL) -> String? {
        let lastModifiedString = TBAKit.lastModifiedURLString(for: url)
        let lastModifiedDictionary = userDefaults.dictionary(forKey: Constants.APIConstants.lastModifiedDictionary) ?? [:]
        return lastModifiedDictionary[lastModifiedString] as? String
    }

    func etag(for url: URL) -> String? {
        let etagString = TBAKit.etagURLString(for: url)
        let etagDictionary = userDefaults.dictionary(forKey: Constants.APIConstants.etagDictionary) ?? [:]
        return etagDictionary[etagString] as? String
    }

    func createRequest(_ method: String) -> URLRequest {
        let apiURL = URL(string: method, relativeTo: Constants.APIConstants.baseURL)!
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "X-TBA-Auth-Key")
        request.addValue("gzip", forHTTPHeaderField: "Accept-Encoding")

        if let lastModified = lastModified(for: apiURL) {
            request.addValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
        }

        if let etag = etag(for: apiURL) {
            request.addValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        return request
    }

    func callApi(method: String) -> AnyPublisher<([String : String], Bool, URLResponse), Error> {
        let request = createRequest(method)
        return urlSession.dataTaskPublisher(for: request).tryMap { (data, response) -> ([String : String], Bool, URLResponse) in
            let httpResponse = response as! HTTPURLResponse
            let unmodified = (httpResponse.statusCode == 304)
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let jsonDict = json as? [String: String] {
                    if let apiError = jsonDict["Error"] {
                        throw APIError.error(apiError)
                    } else {
                        return (jsonDict, unmodified, response)
                    }
                }
            } else {
                // Probably got a 'null' back from the API for the JSON
                throw APIError.error("Unexpected response from server.")
            }
            return ([:], unmodified, response)
        }.eraseToAnyPublisher()
    }

    func callObject<T: TBAModel>(method: String) -> AnyPublisher<(T?, Bool, URLResponse), Error> {
        return callApi(method: method).map { (json, unmodified, response) -> (T?, Bool, URLResponse) in
            if let json = json as? [String: Any] {
                return (T(json: json), unmodified, response)
            } else {
                return (nil, unmodified, response)
            }
        }.eraseToAnyPublisher()
    }
    
    func callArray<T: TBAModel>(method: String) -> AnyPublisher<([T], Bool, URLResponse), Error> {
        return callApi(method: method).tryMap { (json, unmodified, response) -> ([T], Bool, URLResponse) in
            if let json = json as? [[String: Any]] {
                return (json.compactMap({
                    return T(json: $0)
                }), unmodified, response)
            } else {
                throw APIError.error("Unexpected response from server.")
            }
        }.eraseToAnyPublisher()
    }
    
    func callArray(method: String) -> AnyPublisher<([Any], Bool, URLResponse), Error> {
        return callApi(method: method).tryMap { (json, unmodified, response) -> ([Any], Bool, URLResponse) in
            if let json = json as? [Any] {
                return (json, unmodified, response)
            } else {
                throw APIError.error("Unexpected response from server.")
            }
        }.eraseToAnyPublisher()
    }

    func callDictionary(method: String) -> AnyPublisher<([String: Any], Bool, URLResponse), Error> {
        return callApi(method: method).tryMap { (json, unmodified, response) -> ([String: Any], Bool, URLResponse) in
            if let dict = json as? [String: Any] {
                return (dict, unmodified, response)
            } else {
                throw APIError.error("Unexpected response from server.")
            }
        }.eraseToAnyPublisher()
    }
    
}
