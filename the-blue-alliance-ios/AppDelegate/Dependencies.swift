import CoreData
import Foundation
import TBAAPI
import TBAKit
import TBAUtils

class Dependencies {
    let errorRecorder: ErrorRecorder
    let persistentContainer: NSPersistentContainer
    let api: TBAAPI
    let tbaKit: TBAKit
    let userDefaults: UserDefaults
    // TODO: myTBA?

    init(errorRecorder: ErrorRecorder, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, api: TBAAPI, userDefaults: UserDefaults) {
        self.errorRecorder = errorRecorder
        self.persistentContainer = persistentContainer
        self.api = api
        self.tbaKit = tbaKit
        self.userDefaults = userDefaults
    }
}
