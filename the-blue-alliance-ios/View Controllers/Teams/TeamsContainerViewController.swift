import CoreData

import MyTBAKit
import TBAKit
import UIKit

class TeamsContainerViewController: ContainerViewController {

    
    private let myTBA: MyTBA
    
    private let urlOpener: URLOpener

    private(set) var teamsViewController: TeamsViewController!

    // MARK: - Init

    init(myTBA: MyTBA, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        
        self.myTBA = myTBA
        
        self.urlOpener = urlOpener

        teamsViewController = TeamsViewController(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [teamsViewController],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        title = "Teams"
        tabBarItem.image = UIImage.teamIcon

        teamsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension TeamsContainerViewController: TeamsViewControllerDelegate {

    func teamSelected(_ team: Team) {
        // Show detail wrapped in a UINavigationController for our split view controller
        let teamViewController = TeamViewController(team: team, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let nav = UINavigationController(rootViewController: teamViewController)
        navigationController?.showDetailViewController(nav, sender: nil)
    }

}
