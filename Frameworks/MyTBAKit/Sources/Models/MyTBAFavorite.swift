import Combine
import Foundation

struct MyTBAFavoritesRequest: Codable {
    var favorites: [MyTBAFavorite]
}

public struct MyTBAFavoritesResponse: MyTBAResponse {
    var favorites: [MyTBAFavorite]?
}

public struct MyTBAFavorite: MyTBAModel, Equatable, Codable {

    public init(modelKey: String, modelType: MyTBAModelType) {
        self.modelKey = modelKey
        self.modelType = modelType
    }
    
    public static var arrayKey: String {
        return "favorites"
    }

    public var modelKey: String
    public var modelType: MyTBAModelType

    // public static var fetch: (MyTBA) -> () -> AnyPublisher<MyTBAFavoritesResponse, Error> = MyTBA.fetchFavorites
}

extension MyTBA {

    public func fetchFavorites() -> AnyPublisher<MyTBAFavoritesResponse, Error> {
        let method = "\(MyTBAFavorite.arrayKey)/list"
        return callApi(method: method)
    }

}
