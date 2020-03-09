import Combine
import Foundation

public struct MyTBAPreferences: Codable {
    var deviceKey: String?
    var favorite: Bool
    var modelKey: String
    var modelType: MyTBAModelType
    var notifications: [NotificationType]
}

public struct MyTBAPreferencesMessageResponse: MyTBAResponse, Codable {
    let favorite: MyTBABaseResponse
    let subscription: MyTBABaseResponse
}

extension MyTBA {

    // TODO: Android has some local rate limiting, which is probably smart
    // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/174

    public func updatePreferences(modelKey: String, modelType: MyTBAModelType, favorite: Bool, notifications: [NotificationType]) -> AnyPublisher<MyTBAPreferencesMessageResponse, Error> {
        let failurePublisher = PassthroughSubject<MyTBAPreferencesMessageResponse, Error>()

        let preferences = MyTBAPreferences(deviceKey: fcmToken,
                                           favorite: favorite,
                                           modelKey: modelKey,
                                           modelType: modelType,
                                           notifications: notifications)

        do {
            let encodedPreferences = try MyTBA.jsonEncoder.encode(preferences)
            return callApi(method: "model/setPreferences", bodyData: encodedPreferences)
        } catch {
            failurePublisher.send(completion: .failure(error))
            return failurePublisher.eraseToAnyPublisher()
        }
    }

}
