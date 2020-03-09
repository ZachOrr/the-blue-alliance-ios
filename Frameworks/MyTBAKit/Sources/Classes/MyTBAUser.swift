import Foundation

public protocol MyTBAUser {
    func getIDToken(completion: ((String?, Error?) -> ())?)
}
