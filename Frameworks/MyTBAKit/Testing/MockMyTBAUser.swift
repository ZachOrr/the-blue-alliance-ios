import Foundation
import MyTBAKit

public class MockMyTBAUser: MyTBAUser {

    public var mockAuthToken: String?
    public var mockError: Error?

    public init(mockAuthToken: String? = "abcd123", mockError: Error? = nil) {
        self.mockAuthToken = mockAuthToken
        self.mockError = mockError
    }

    public func getIDToken(completion: ((String?, Error?) -> ())?) {
        completion?(mockAuthToken, mockError)
    }

}
