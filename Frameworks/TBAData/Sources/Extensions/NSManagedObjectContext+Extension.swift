import CoreData
import Foundation
import TBAUtils

extension NSManagedObject {

    /** Syncronous, thread-safe method to get a typed value from a NSManagedObject. **/
    func getValue<T, J>(_ keyPath: KeyPath<T, J>) -> J {
        guard let context = managedObjectContext else {
            fatalError("No managedObjectContext for object.")
        }
        guard let value = context.getKeyPathAndWait(obj: self, keyPath: keyPath) else {
            fatalError("No value for keyPath \(keyPath)")
        }
        return value
    }

}

extension NSManagedObjectContext {

    public func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
        return obj
    }

    @discardableResult
    public func saveOrRollback(errorRecorder: ErrorRecorder) -> Bool {
        do {
            try save()
            return true
        } catch {
            print(error)
            errorRecorder.recordError(error)
            rollback()
            return false
        }
    }

    public func performSaveOrRollback(errorRecorder: ErrorRecorder) {
        perform {
            _ = self.saveOrRollback(errorRecorder: errorRecorder)
        }
    }

    public func performChanges(_ block: @escaping () -> Void, errorRecorder: ErrorRecorder) {
        perform {
            block()
            _ = self.saveOrRollback(errorRecorder: errorRecorder)
        }
    }

    public func performChangesAndWait(_ block: @escaping () -> Void, saved: (() -> ())? = nil, errorRecorder: ErrorRecorder) {
        performAndWait {
            block()
            if self.saveOrRollback(errorRecorder: errorRecorder) {
                saved?()
            }
        }
    }

    public func performAndWait<T>(_ block: () -> T) -> T {
        var result: T!
        performAndWait {
            result = block()
        }
        return result
    }

    public func performAndWait<T>(_ block: () -> T?) -> T? {
        var result: T? = nil
        performAndWait {
            result = block()
        }
        return result
    }

    fileprivate func getKeyPathAndWait<T, J>(obj: NSManagedObject, keyPath: KeyPath<T, J>) -> J? {
        guard let keyPathString = keyPath._kvcKeyPathString else {
            fatalError("Unable to get key path string for \(keyPath)")
        }
        return performAndWait {
            return obj.value(forKeyPath: keyPathString) as? J
        }
    }

    fileprivate func setKeyPathAndWait<T, J>(obj: NSManagedObject, value: J, keyPath: KeyPath<T, J>) {
        guard let keyPathString = keyPath._kvcKeyPathString else {
            fatalError("Unable to get key path string for \(keyPath)")
        }
        performAndWait {
            obj.setValue(value, forKeyPath: keyPathString)
        }
    }

    fileprivate func setNilKeyPathAndWait<T, J>(obj: NSManagedObject, keyPath: KeyPath<T, J>) {
        guard let keyPathString = keyPath._kvcKeyPathString else {
            fatalError("Unable to get key path string for \(keyPath)")
        }
        performAndWait {
            obj.setNilValueForKey(keyPathString)
        }
    }

    public func deleteAllObjects() {
        for entity in persistentStoreCoordinator?.managedObjectModel.entities ?? [] {
            deleteAllObjectsForEntity(entity: entity)
        }
    }

    public func deleteAllObjectsForEntity(entity: NSEntityDescription) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! executeAndMergeChanges(deleteRequest)
    }

    /// Executes the given `NSBatchInsertRequest` and directly merges the changes to bring the given managed object context up to date.
    ///
    /// - Parameter request: The `NSBatchInsertRequest` to execute.
    /// - Throws: An error if anything went wrong executing the batch deletion.
    public func executeAndMergeChanges(_ request: NSBatchInsertRequest) throws {
        request.resultType = .objectIDs
        let result = try execute(request) as? NSBatchInsertResult
        let changes: [AnyHashable: Any] = [NSInsertedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]

        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self, self.parent!])
    }

    /// Executes the given `NSBatchDeleteRequest` and directly merges the changes to bring the given managed object context up to date.
    ///
    /// - Parameter request: The `NSBatchDeleteRequest` to execute.
    /// - Throws: An error if anything went wrong executing the batch deletion.
    public func executeAndMergeChanges(_ request: NSBatchDeleteRequest) throws {
        request.resultType = .resultTypeObjectIDs
        let result = try execute(request) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]

        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }

}
