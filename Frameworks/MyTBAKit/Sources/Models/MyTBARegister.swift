import Combine
import Foundation

public struct MyTBARegisterRequest: Codable {
    var deviceUuid: String
    var mobileId: String
    var name: String
    internal let operatingSystem: String = "ios"
}

extension MyTBA {

    public func register() -> AnyPublisher<MyTBABaseResponse, Error> {
        return registerUnregister("register")
    }

    public func unregister() -> AnyPublisher<MyTBABaseResponse, Error> {
        return registerUnregister("unregister")
    }

    private func registerUnregister(_ method: String) -> AnyPublisher<MyTBABaseResponse, Error> {
        let failurePublisher = PassthroughSubject<MyTBABaseResponse, Error>()

        guard let token = fcmToken else {
            failurePublisher.send(completion: .failure(MyTBAError.error(nil, "No FCM token for myTBA user")))
            return failurePublisher.eraseToAnyPublisher()
        }

        let registration = MyTBARegisterRequest(deviceUuid: uuid, mobileId: token, name: deviceName)
        do {
            let encodedRegistration = try MyTBA.jsonEncoder.encode(registration)
            return callApi(method: method, bodyData: encodedRegistration)
        } catch {
            failurePublisher.send(completion: .failure(error))
            return failurePublisher.eraseToAnyPublisher()
        }

    }

}
