import Combine
import Foundation

struct MyTBAPingRequest: Codable {
    var mobileId: String
}

extension MyTBA {

    public func ping() -> AnyPublisher<MyTBABaseResponse, Error> {
        let failurePublisher = PassthroughSubject<MyTBABaseResponse, Error>()

        guard let token = fcmToken else {
            failurePublisher.send(completion: .failure(MyTBAError.error(nil, "No FCM token for myTBA user")))
            return failurePublisher.eraseToAnyPublisher()
        }

        let ping = MyTBAPingRequest(mobileId: token)
        do {
            let encodedPing = try MyTBA.jsonEncoder.encode(ping)
            return callApi(method: "ping", bodyData: encodedPing)
        } catch {
            failurePublisher.send(completion: .failure(error))
            return failurePublisher.eraseToAnyPublisher()
        }
    }

}
