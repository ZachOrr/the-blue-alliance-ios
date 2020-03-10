import Foundation
import TBAOperation

// TODO: Move this out
protocol MyTBAUser {
    func getToken(completion: ((String?, Error) -> ()?))
}

public class MyTBAOperation: TBAOperation {

    var tokenOperation: Operation
    // var persistentContainerOperation: PersistentContainerOperation

    let operationQueue = OperationQueue()

    public init<T: MyTBAResponse>(myTBA: MyTBA, method: String, bodyData: Data? = nil, completion: @escaping (T?, Error?) -> Void) {
        // tokenOperation = TokenOperation(user: myTBA)
    }

    /*
    override open func execute() {
        let blockOperation = BlockOperation { [unowned self] in
            self.completionError = [self.destroyPersistentStoreOperation, self.persistentContainerOperation].compactMap({ $0.completionError }).first
            self.finish()
        }

        let dependentOperations = [destroyPersistentStoreOperation, persistentContainerOperation]
        for op in dependentOperations {
            blockOperation.addDependency(op)
        }
        appSetupOperationQueue.addOperations(dependentOperations + [blockOperation], waitUntilFinished: false)
        // task.resume()
    }
    */

    override open func cancel() {
        operationQueue.cancelAllOperations()

        super.cancel()
    }

}

private class TokenOperation: TBAOperation {

    private let user: MyTBAUser

    public init(user: MyTBAUser) {
        self.user = user
    }

    override open func execute() {
        user.getToken { (authToken, error) in
            // Pass
        }
    }

}

private class MyTBAKitOperation: TBAOperation {

    var task: URLSessionTask!

    public init<T: MyTBAResponse>(myTBA: MyTBA, method: String, bodyData: Data? = nil, completion: @escaping (T?, Error?) -> Void) {
        super.init()

        let request = myTBA.createRequest(method, bodyData)
        task = myTBA.urlSession.dataTask(with: request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                #if DEBUG
                if let dataString = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print(dataString)
                }
                #endif

                var decodedResponse: T?
                do {
                    decodedResponse = try MyTBA.jsonDecoder.decode(T.self, from: data)
                } catch {
                    completion(nil, error)
                    self?.finish()
                    return
                }

                if let myTBAResponse = decodedResponse as? MyTBABaseResponse {
                    completion(decodedResponse, error ?? myTBAResponse.error)
                } else {
                    completion(decodedResponse, error)
                }
            } else {
                completion(nil, MyTBAError.error(nil, "Unexpected response from myTBA API"))
            }

            self?.finish()
        }
    }

    override open func execute() {
        task.resume()
    }

    override open func cancel() {
        task.cancel()

        super.cancel()
    }

}
