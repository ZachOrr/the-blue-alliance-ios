import CoreData
import Foundation
import MyTBAKit
import TBAData
import TBAKit

// The myTBA service is meant to keep local myTBA models up-to-date
class MyTBAService {

    // Used to dispatch fetched Event/Team/Match/etc. models to subscribers
    public var myTBAModelProviderProvider = Provider<MyTBAModelProvider>()
    
    private let operationQueue = OperationQueue()
    private var favoritesOperation: MyTBAOperation?

    private let tbaKit: TBAKit
    private let myTBA: MyTBA
    private let persistentContainer: NSPersistentContainer
    internal var retryService: RetryService
    private let errorRecorder: ErrorRecorder

    init(tbaKit: TBAKit, myTBA: MyTBA, persistentContainer: NSPersistentContainer, retryService: RetryService, errorRecorder: ErrorRecorder) {
        self.tbaKit = tbaKit
        self.myTBA = myTBA
        self.persistentContainer = persistentContainer
        self.retryService = retryService
        self.errorRecorder = errorRecorder
    }

    func updateFavorites() {
        // Only allow one favorites fetch at a time
        guard favoritesOperation == nil else {
            return
        }

        let favoritesOperation = myTBA.fetchFavorites { [unowned self] (favorites, _) in
            print("Fetched favorites: \(favorites ?? [])")
            self.favoritesOperation = nil

            let context = self.persistentContainer.newBackgroundContext()
            context.performChanges({
                guard let favorites = favorites else {
                    return
                }
                Favorite.insert(favorites, in: context)
                favorites.forEach({
                    guard let tbaOperation = self.tbaObjectOperation($0) else {
                        return
                    }
                    self.operationQueue.addOperation(tbaOperation)
                })
                /*
                } else if error == nil {
                    // If we don't get any models and we don't have an error, we probably don't have any models upstream
                    context.deleteAllObjectsForEntity(entity: T.entity())
                }
                */
            }, errorRecorder: self.errorRecorder)
        }
        self.favoritesOperation = favoritesOperation
        operationQueue.addOperation(favoritesOperation)
    }

    private func tbaObjectOperation(_ myTBAModel: MyTBAModel) -> TBAKitOperation? {
        switch myTBAModel.modelType {
        case .event:
            return self.fetchEvent(myTBAModel)
        case .team:
            return self.fetchTeam(myTBAModel)
        case .match:
            return self.fetchMatch(myTBAModel)
        default:
            return nil
        }
    }

    @discardableResult
    private func fetchEvent(_ model: MyTBAModel) -> TBAKitOperation {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEvent(key: model.modelKey) { [unowned self] (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let event = try? result.get() {
                    Event.insert(event, in: context)
                    self.myTBAModelProviderProvider.post(block: { (observer) in
                        observer.myTBAModelObjectFetched(model: model)
                    })
                }
            }, saved: {
                self.tbaKit.storeCacheHeaders(operation)
            }, errorRecorder: self.errorRecorder)
        }
        return operation
    }

    @discardableResult
    private func fetchTeam(_ model: MyTBAModel) -> TBAKitOperation {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchTeam(key: model.modelKey) { [unowned self] (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let team = try? result.get() {
                    Team.insert(team, in: context)
                    self.myTBAModelProviderProvider.post(block: { (observer) in
                        observer.myTBAModelObjectFetched(model: model)
                    })
                }
            }, saved: {
                self.tbaKit.storeCacheHeaders(operation)
            }, errorRecorder: self.errorRecorder)
        }
        return operation
    }

    @discardableResult
    private func fetchMatch(_ model: MyTBAModel) -> TBAKitOperation {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchMatch(key: model.modelKey) { [unowned self] (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let match = try? result.get() {
                    Match.insert(match, in: context)
                    self.myTBAModelProviderProvider.post(block: { (observer) in
                        observer.myTBAModelObjectFetched(model: model)
                    })
                }
            }, saved: {
                self.tbaKit.storeCacheHeaders(operation)
            }, errorRecorder: self.errorRecorder)
        }
        return operation
    }

}

extension MyTBAService: Retryable {

    var retryInterval: TimeInterval {
        // Update myTBA models every minute
        return 60
    }

    func retry() {
        guard myTBA.isAuthenticated else {
            return
        }
        updateFavorites()
    }

}

extension MyTBAService: MyTBAAuthenticationObservable {

    func authenticated() {
        updateFavorites()
    }

    func unauthenticated() {
        // Don't worry about canceling during unregisters
    }

}

public protocol MyTBAModelProvider {
    func myTBAModelObjectFetched(model: MyTBAModel)
}
