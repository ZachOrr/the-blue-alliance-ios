//import MyTBAKit
//import MyTBAKitTesting
//import XCTest
//
//class MyTBAPreferencesTests: MyTBATestCase {
//
//    func test_preferences() {
//        myTBA.user = MockMyTBAUser()
//
//        let ex = expectation(description: "model/setPreferences called")
//        let operations = myTBA.updatePreferences(modelKey: "2018ckw0", modelType: .event, favorite: true, notifications: []) { (favoriteResponse, subscriptionResponse, error) in
//            XCTAssertNotNil(favoriteResponse)
//            XCTAssertNotNil(subscriptionResponse)
//            XCTAssertNil(error)
//            ex.fulfill()
//        }
//        let operation = operations!.last as! MyTBAKitOperation
//
//        myTBA.sendStub(for: operation)
//        wait(for: [ex], timeout: 1.0)
//    }
//
//    func test_preferences_error() {
//        myTBA.user = MockMyTBAUser()
//
//        let ex = expectation(description: "model/setPreferences called")
//        let operations = myTBA.updatePreferences(modelKey: "2018ckw0", modelType: .event, favorite: true, notifications: []) { (favoriteResponse, subscriptionResponse, error) in
//            XCTAssertNotNil(error)
//            XCTAssertNil(favoriteResponse)
//            XCTAssertNil(subscriptionResponse)
//            ex.fulfill()
//        }
//        let operation = operations!.last as! MyTBAKitOperation
//
//        myTBA.sendStub(for: operation, code: 401)
//        wait(for: [ex], timeout: 1.0)
//    }
//
//    func test_unauthenticated() {
//        let operations = myTBA.updatePreferences(modelKey: "2018ckw0", modelType: .event, favorite: true, notifications: []) { (favoriteResponse, subscriptionResponse, error) in
//            // Pass
//        }
//        XCTAssertNil(operations)
//    }
//
//}
