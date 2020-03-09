import Combine
import MyTBAKit
import MyTBAKitTesting
import XCTest

class MyTBARegisterTests: MyTBATestCase {

    var sinks: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        sinks = Set()
    }

    override func tearDown() {
        sinks = nil

        super.tearDown()
    }

    func test_register() {
        myTBA.user = MockMyTBAUser()
        fcmTokenProvider.fcmToken = "abc"

        let completionExpectation = expectation(description: "Register called")

        let a = myTBA.register()
        a.sink(receiveCompletion: { (completion) in
            switch completion {
                case .finished:
                    print("Finished")
                    completionExpectation.fulfill()
                case .failure:
                    print("Failure")
                    XCTFail()
            }
        }, receiveValue: {
            XCTAssertNotNil($0)
        }).store(in: &sinks)

        myTBA.sendStub(method: "register", code: 401)

        wait(for: [completionExpectation], timeout: 1.0)
    }

    /*
    func test_register_error() {
        myTBA.user = MockMyTBAUser()
        fcmTokenProvider.fcmToken = "abc"

        let ex = expectation(description: "Register called")
        let operations = myTBA.register { (_, error) in
            XCTAssertNotNil(error)
            ex.fulfill()
        }
        let operation = operations!.last as! MyTBAKitOperation

        myTBA.sendStub(for: operation, code: 401)
        wait(for: [ex], timeout: 1.0)
    }

    func test_unauthenticated() {
        let operations = myTBA.register { (_, _) in
            // Pass
        }
        XCTAssertNil(operations)
    }
    */

}
