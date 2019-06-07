import CoreData

import Foundation
import MyTBAKit
import TBAKit
import UIKit

class TeamAtDistrictViewController: ContainerViewController, ContainerTeamPushable {

    internal var teamKey: TeamKey {
        return ranking.teamKey!
    }

    private(set) var ranking: DistrictRanking
    
    
    let myTBA: MyTBA
    let urlOpener: URLOpener

    private var summaryViewController: DistrictTeamSummaryViewController!

    // MARK: Init

    init(ranking: DistrictRanking, myTBA: MyTBA, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.ranking = ranking
        
        self.myTBA = myTBA
        
        self.urlOpener = urlOpener

        let summaryViewController = DistrictTeamSummaryViewController(ranking: ranking, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let breakdownViewController = DistrictBreakdownViewController(ranking: ranking, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(
            viewControllers: [summaryViewController, breakdownViewController],
            navigationTitle: "Team \(ranking.teamKey!.teamNumber)",
            navigationSubtitle: "@ \(ranking.district!.abbreviationWithYear)",
            segmentedControlTitles: ["Summary", "Breakdown"],
            persistentContainer: persistentContainer,
            tbaKit: tbaKit,
            userDefaults: userDefaults
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.teamIcon, style: .plain, target: self, action: #selector(pushTeam))

        summaryViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    @objc private func pushTeam() {
        _pushTeam(attemptedToLoadTeam: false)
    }

}

extension TeamAtDistrictViewController: DistrictTeamSummaryViewControllerDelegate {

    func eventPointsSelected(_ eventPoints: DistrictEventPoints) {
        // TODO: Support Team@Event taking a EventKey
        guard let event = eventPoints.eventKey?.event else {
            return
        }

        // TODO: Let's see what we can to do not force-unwrap these from Core Data
        let teamAtEventViewController = TeamAtEventViewController(teamKey: eventPoints.teamKey!, event: event, myTBA: myTBA, showDetailEvent: true, showDetailTeam: false, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
