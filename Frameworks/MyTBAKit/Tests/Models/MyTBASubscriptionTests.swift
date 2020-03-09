//import MyTBAKit
//import MyTBAKitTesting
//import XCTest
//
//class MyTBASubscriptionTests: MyTBATestCase {
//
//    func test_subscriptions() {
//        myTBA.user = MockMyTBAUser()
//
//        let ex = expectation(description: "subscriptions/list called")
//        let operations = myTBA.fetchSubscriptions { (subscriptions, error) in
//            XCTAssertNotNil(subscriptions)
//            XCTAssertEqual(subscriptions?.count, 3)
//            XCTAssertNil(error)
//            ex.fulfill()
//        }
//        let operation = operations!.last as! MyTBAKitOperation
//
//        myTBA.sendStub(for: operation)
//        wait(for: [ex], timeout: 1.0)
//    }
//
//    func test_subscriptions_empty() {
//        myTBA.user = MockMyTBAUser()
//
//        let ex = expectation(description: "subscriptions/list called")
//        let operations = myTBA.fetchSubscriptions { (subscriptions, error) in
//            XCTAssertNil(subscriptions)
//            XCTAssertNil(error)
//            ex.fulfill()
//        }
//        let operation = operations!.last as! MyTBAKitOperation
//
//        myTBA.sendStub(for: operation, code: 201)
//        wait(for: [ex], timeout: 1.0)
//    }
//
//    func test_unauthenticated() {
//        let operations = myTBA.fetchSubscriptions { (_, _) in
//            // Pass
//        }
//        XCTAssertNil(operations)
//    }
//
//}
