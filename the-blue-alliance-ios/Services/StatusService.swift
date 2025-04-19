import Foundation
import TBAAPI
import TBAUtils

enum StatusServiceError: Error {
    case missingStatusDefaultsFile
}

/**
 Service to periodically fetch from the /status endpoint
 */
public class StatusService: NSObject {

    private let api: TBAAPI
    private let errorRecorder: ErrorRecorder
    var retryService: RetryService

    var status: Status

    // Keep internal state of previously-down Events so we can dispatch when they're back up
    private var previousFMSStatus: Bool = false
    private var previouslyDownEventKeys: [String] = []

    var currentSeason: Int {
        return status.currentSeason
    }

    var maxSeason: Int {
        return status.maxSeason
    }

    init(bundle: Bundle = Bundle.main, api: TBAAPI, errorRecorder: ErrorRecorder, retryService: RetryService) throws {
        self.api = api
        self.errorRecorder = errorRecorder
        self.retryService = retryService

        self.status = try StatusService.statusFromDefaults(in: bundle)

        super.init()
    }

    private static func statusFromDefaults(in bundle: Bundle) throws -> Status {
        guard let defaultsURL = bundle.url(forResource: "StatusDefaults", withExtension: "plist") else {
            throw StatusServiceError.missingStatusDefaultsFile
        }

        let data = try Data(contentsOf: defaultsURL)

        let decoder = PropertyListDecoder()
        return try decoder.decode(Status.self, from: data)
    }
}

extension StatusService: Retryable {

    var retryInterval: TimeInterval {
        // Poll every... 5 mins for a new status object
        return 5 * 60
    }

    // TODO: Move to async
    func retry() {
        Task {
            do {
                self.status = try await api.getStatus()
            } catch {
                errorRecorder.record(error)
            }
        }
    }

}
