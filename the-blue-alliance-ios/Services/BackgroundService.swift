import BackgroundTasks
import Foundation
import MyTBAKit
import TBAUtils

let TBABackgroundTaskMyTBAIdentifier = "com.the-blue-alliance.tba.mytba"
let TBABackgroundTaskSearchIdentifier = "com.the-blue-alliance.tba.search"
let TBABackgroundTaskStatusIdentifier = "com.the-blue-alliance.tba.status"

class BackgroundService {

    static var backgroundTaskIdentifiers: [String] {
        return [
            TBABackgroundTaskMyTBAIdentifier,
            TBABackgroundTaskSearchIdentifier,
            TBABackgroundTaskStatusIdentifier
        ]
    }

    private let errorRecorder: ErrorRecorder
    private let statusService: StatusService
    private let taskScheduler: BGTaskScheduler

    private let operationQueue = OperationQueue()

    // Probably needs a SearchService
    init(errorRecorder: ErrorRecorder, statusService: StatusService, taskScheduler: BGTaskScheduler) {
        self.errorRecorder = errorRecorder
        self.statusService = statusService
        self.taskScheduler = taskScheduler
    }

    // MARK: - Public Methods

    public func handleBackgroundTask(_ task: BGTask) {
        if task.identifier == TBABackgroundTaskMyTBAIdentifier {
            handleUpdateMyTBA(task)
        } else if task.identifier == TBABackgroundTaskSearchIdentifier {
            handleUpdateSearch(task)
        }
    }

    public func scheduleBackgroundTasks() {
        // Note: We DON'T schedule myTBA here, since it'll be scheduled after a user signs in to myTBA
        scheduleUpdateSearchIfNeeded()
    }

    // MARK: - Private Methods
    // TODO: Can we run these *periodically* or no?

    // MARK: - Push (Registration)

    private func handleRegisterPush() {

    }

    public func scheduleRegisterPush() {

    }

    // MARK: - myTBA

    private func handleUpdateMyTBA(_ task: BGTask) {
        scheduleUpdateMyTBA()

        // TODO: Fetch myTBA shit... myTBA service anyone?
    }

    private func scheduleUpdateMyTBA() {
        let request = BGAppRefreshTaskRequest(identifier: TBABackgroundTaskMyTBAIdentifier)
        // TODO: See what propertities we have here
        do {
            try taskScheduler.submit(request)
        } catch {
            errorRecorder.recordError(error)
        }
    }

    // TODO: Push service stuff? What if we fail to register a push token?

    // MARK: - Search

    func handleUpdateSearch(_ task: BGTask) {
        let queue = OperationQueue()

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        let lastOperation = Operation()
        lastOperation.completionBlock = {
            task.setTaskCompleted(success: !lastOperation.isCancelled)
        }
    }

    func scheduleUpdateSearchIfNeeded() {
        // TODO: Check last time, create request, submit
        let request = BGProcessingTaskRequest(identifier: TBABackgroundTaskSearchIdentifier)
        request.requiresNetworkConnectivity = true
        // TODO: We should probably schedule this for like, a week in the future? That's what we're doing right?

        do {
            try taskScheduler.submit(request)
        } catch {
            errorRecorder.recordError(error)
        }
    }

    // MARK: - Status

    func handleUpdateStatus(_ task: BGTask) {
        scheduleUpdateStatus()

        let operation = statusService.fetchStatus()
        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }

        task.expirationHandler = {
            operation.cancel()
        }

        operationQueue.addOperation(operation)
    }

    func scheduleUpdateStatus() {
        let request = BGAppRefreshTaskRequest(identifier: TBABackgroundTaskStatusIdentifier)
        do {
            try taskScheduler.submit(request)
        } catch {
            errorRecorder.recordError(error)
        }
    }

}
