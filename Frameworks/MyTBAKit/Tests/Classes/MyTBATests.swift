//import MyTBAKitTesting
//import XCTest
//@testable import MyTBAKit
//
//class MyTBAErrorTests: XCTestCase {
//
//    func test_code() {
//        let errorNoCode = MyTBAError.error(nil, "")
//        XCTAssertNil(errorNoCode.code)
//
//        let error = MyTBAError.error(210, "")
//        XCTAssertEqual(error.code, 210)
//    }
//
//    func test_errorMessage() {
//        let errorMessage = "Testing error message"
//        let error = MyTBAError.error(nil, errorMessage)
//        XCTAssertEqual(error.localizedDescription, errorMessage)
//    }
//
//}
//
//class MyTBATests: MyTBATestCase {
//
//    func test_init() {
//        let uuid = "abcd123"
//        let deviceName = "My Device"
//        let fcmToken = "abc"
//
//        let mfcm = MockFCMTokenProvider(fcmToken: fcmToken)
//        let zz = MyTBA(uuid: uuid, deviceName: deviceName, fcmTokenProvider: mfcm)
//        XCTAssertEqual(zz.uuid, uuid)
//        XCTAssertEqual(zz.deviceName, deviceName)
//        XCTAssertEqual(zz.fcmToken, fcmToken)
//    }
//
//    func test_authenticationProvider_authenticated() {
//        let authObserver = MockAuthObserver()
//        myTBA.authenticationProvider.add(observer: authObserver)
//
//        XCTAssertNil(myTBA.user)
//
//        let authenticatedExpectation = expectation(description: "myTBA Authenticated")
//        authObserver.authenticatedExpectation = authenticatedExpectation
//        myTBA.user = MockMyTBAUser()
//        wait(for: [authenticatedExpectation], timeout: 1.0)
//    }
//
//    func test_authenticationProvider_noChange() {
//        let authObserver = MockAuthObserver()
//        myTBA.authenticationProvider.add(observer: authObserver)
//
//        XCTAssertNil(myTBA.user)
//        let user = MockMyTBAUser()
//        myTBA.user = user
//
//        let authenticatedExpectation = expectation(description: "myTBA Authenticated")
//        authenticatedExpectation.isInverted = true
//        authObserver.authenticatedExpectation = authenticatedExpectation
//        myTBA.user = user
//
//        wait(for: [authenticatedExpectation], timeout: 1.0)
//    }
//
//    func test_authenticationProvider_changed() {
//        let authObserver = MockAuthObserver()
//        myTBA.authenticationProvider.add(observer: authObserver)
//
//        XCTAssertNil(myTBA.user)
//        let user = MockMyTBAUser()
//        myTBA.user = user
//
//        let authenticatedExpectation = expectation(description: "myTBA Authenticated")
//        authObserver.authenticatedExpectation = authenticatedExpectation
//        myTBA.user = MockMyTBAUser()
//
//        wait(for: [authenticatedExpectation], timeout: 1.0)
//    }
//
//    func test_authenticationProvider_unauthenticated() {
//        let authObserver = MockAuthObserver()
//        myTBA.authenticationProvider.add(observer: authObserver)
//
//        XCTAssertNil(myTBA.user)
//        myTBA.user = MockMyTBAUser()
//
//        let unauthenticatedExpectation = expectation(description: "myTBA Unauthenticated")
//        authObserver.unauthenticatedExpectation = unauthenticatedExpectation
//        myTBA.user = nil
//
//        wait(for: [unauthenticatedExpectation], timeout: 1.0)
//    }
//
//    func test_isAuthenticated() {
//        XCTAssertFalse(myTBA.isAuthenticated)
//        myTBA.user = MockMyTBAUser()
//        XCTAssert(myTBA.isAuthenticated)
//        myTBA.user = nil
//        XCTAssertFalse(myTBA.isAuthenticated)
//    }
//
//    func test_jsonEncoder() {
//        let jsonEncoder = MyTBA.jsonEncoder
//        XCTAssertNotNil(jsonEncoder)
//    }
//
//    func test_jsonDecoder() {
//        let jsonDecoder = MyTBA.jsonDecoder
//        XCTAssertNotNil(jsonDecoder)
//    }
//
//    func test_callApi_hasBearer() {
//        myTBA.user = MockMyTBAUser()
//        let operations = myTBA.callApi(method: "test") { (registerResponse: MyTBABaseResponse?, error: Error?) in
//            // NOP
//        }
//        let authOperation = operations!.first as! MyTBAAuthOperation
//        authOperation.execute()
//
//        let operation = operations!.last as! MyTBAKitOperation
//
//        guard let request = operation.task.currentRequest else {
//            XCTFail()
//            return
//        }
//        XCTAssertEqual(request.httpMethod, "POST")
//
//        guard let headers = request.allHTTPHeaderFields else {
//            XCTFail()
//            return
//        }
//        guard let authorizationHeader = headers["Authorization"] else {
//            XCTFail()
//            return
//        }
//        XCTAssert(authorizationHeader.contains("Bearer"))
//    }
//
//}
//
//private class MockAuthObserver: MyTBAAuthenticationObservable {
//
//    var authenticatedExpectation: XCTestExpectation?
//    var unauthenticatedExpectation: XCTestExpectation?
//
//    func authenticated() {
//        authenticatedExpectation?.fulfill()
//    }
//
//    func unauthenticated() {
//        unauthenticatedExpectation?.fulfill()
//    }
//}
