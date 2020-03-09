import Combine
import Foundation
import TBAUtils

struct APIConstants {
    static let baseURL = URL(string: "https://www.thebluealliance.com/clientapi/tbaClient/v9/")!
}

public enum MyTBAError: Error {
    case error(Int?, String)

    public var code: Int? {
        switch self {
        case .error(let code, _):
            return code
        }
    }
}

extension MyTBAError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error(_, let message):
            // TODO: This, unlike the name says, isn't localized
            return message
        }
    }
}

open class MyTBA {

    // This is public, which is terrible, because it shouldn't be. But we need it so in TBA
    // when Firebase Auth changes, we can remove the token
    public var user: MyTBAUser? {
        didSet {
            /*
            // Only dispatch on changed state
            if oldValue == user {
                return
            }
            */

            authenticationProvider.post { (observer) in
                if user == nil {
                    observer.unauthenticated()
                } else {
                    observer.authenticated()
                }
            }
        }
    }

    public var isAuthenticated: Bool {
        return user != nil
    }

    public init(uuid: String, deviceName: String, fcmTokenProvider: FCMTokenProvider, urlSession: URLSession = URLSession(configuration: .default)) {
        self.uuid = uuid
        self.deviceName = deviceName
        self.fcmTokenProvider = fcmTokenProvider
        self.urlSession = urlSession
    }

    public var authenticationProvider = Provider<MyTBAAuthenticationObservable>()

    internal var fcmToken: String? {
        return fcmTokenProvider.fcmToken
    }

    internal var urlSession: URLSession
    internal var uuid: String
    internal var deviceName: String
    private var fcmTokenProvider: FCMTokenProvider

    static var jsonEncoder: JSONEncoder {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        return jsonEncoder
    }

    static var jsonDecoder: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }

    func createRequest(_ method: String, authToken: String, _ bodyData: Data? = nil) -> URLRequest {
        let apiURL = URL(string: method, relativeTo: APIConstants.baseURL)!
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"

        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        #if DEBUG
        if let bodyData = bodyData, let dataString = try? JSONSerialization.jsonObject(with: bodyData, options: []) {
            print("POST \(method): \(dataString)")
        }
        #endif

        request.httpBody = bodyData

        return request
    }

    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher {
        return urlSession.dataTaskPublisher(for: request)
    }

    func callApi<T: MyTBAResponse>(method: String, bodyData: Data? = nil) -> AnyPublisher<T, Error> {
        let tokenPublisher = CurrentValueSubject<String?, Error>(nil)
        guard let user = user else {
            let publisher = PassthroughSubject<T, Error>()
            publisher.send(completion: .failure(MyTBAError.error(nil, "No user for myTBA")))
            return publisher.eraseToAnyPublisher()
        }

        let token = user.getIDToken(completion: { (authToken, error) in
            if let error = error {
                tokenPublisher.send(completion: .failure(error))
            } else if let authToken = authToken {
                tokenPublisher.send(authToken)
            } else {
                tokenPublisher.send(completion: .failure(MyTBAError.error(nil, "Could not fetch token for myTBA user")))
            }
        })

        // TODO: Make sure we call `finish` here at some point?
        return tokenPublisher.compactMap {
            guard let authToken = $0 else {
                return nil
            }
            return self.createRequest(method, authToken: authToken, bodyData)
        }.flatMap {
            self.dataTaskPublisher(for: $0)
                .map { $0.data }
                .decode(type: T.self, decoder: MyTBA.jsonDecoder)
        }.eraseToAnyPublisher()
    }

}

public protocol MyTBAAuthenticationObservable {
    func authenticated()
    func unauthenticated()
}
