import Combine
import TBATestingMocks
import XCTest
@testable import MyTBAKit

public class MockFCMTokenProvider: FCMTokenProvider {
    public var fcmToken: String?

    public init(fcmToken: String?) {
        self.fcmToken = fcmToken
    }
}

public class MockMyTBA: MyTBA {

    private let bundle: Bundle
    private let mockSubject = PassthroughSubject<(Data, URLResponse), URLError>()

    public init(fcmTokenProvider: FCMTokenProvider) {
        let selfBundle = Bundle(for: type(of: self))
        guard let resourceURL = selfBundle.resourceURL?.appendingPathComponent("MyTBAKitTesting.bundle"),
            let bundle = Bundle(url: resourceURL) else {
                fatalError("Unable to find MyTBAKitTesting.bundle")
        }
        self.bundle = bundle

        super.init(uuid: "abcd123",
                   deviceName: "MyTBATesting",
                   fcmTokenProvider: fcmTokenProvider)
    }

    public func sendStub(method: String, code: Int = 200) {
        var filepath = method
        if code != 200 {
            filepath.append("_\(code)")
        }

        guard let resourceURL = bundle.url(forResource: filepath, withExtension: "json") else {
            XCTFail("Cannot find file \(filepath).json")
            return
        }

        do {
            let data = try Data(contentsOf: resourceURL)
            let response = HTTPURLResponse(url: URL(string: "https://zachorr.com")!, statusCode: code, httpVersion: nil, headerFields: nil)!
            mockSubject.send((data, response))
        } catch {
            XCTFail()
        }
    }

    override public func dataTaskPublisher(for request: URLRequest) -> MyTBADataTaskPublisher {
        return mockSubject as! MyTBADataTaskPublisher
    }

}

public protocol MyTBADataTaskPublisher: Publisher {
    typealias Output = (data: Data, response: URLResponse)
    typealias Failure = URLError
}
