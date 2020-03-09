//import MyTBAKit
//import MyTBAKitTesting
//import XCTest
//
//class MyTBAFavoriteTests: MyTBATestCase {
//
//    func test_favorites() {
//        myTBA.user = MockMyTBAUser()
//
//        let ex = expectation(description: "favorites/list called")
//        let operations = myTBA.fetchFavorites { (favorites, error) in
//            XCTAssertNotNil(favorites)
//            XCTAssertEqual(favorites?.count, 3)
//            XCTAssertNil(error)
//            ex.fulfill()
//        }
//        let operation = operations!.last as! MyTBAKitOperation
//
//        myTBA.sendStub(for: operation)
//        wait(for: [ex], timeout: 1.0)
//    }
//
//    func test_favorites_empty() {
//        myTBA.user = MockMyTBAUser()
//
//        let ex = expectation(description: "favorites/list called")
//        let operations = myTBA.fetchFavorites { (favorites, error) in
//            XCTAssertNil(favorites)
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
//        let operations = myTBA.fetchFavorites { (_, _) in
//            // Pass
//        }
//        XCTAssertNil(operations)
//    }
//
//}
