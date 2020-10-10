import CoreData
import Foundation
import TBAKit
import UIKit

class GameDayWebcastsViewController: TBATableViewController {

    init(persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
