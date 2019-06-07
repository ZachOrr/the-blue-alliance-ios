import CoreData

import Foundation
import MyTBAKit
import TBAKit
import UIKit

class TeamAtEventViewController: ContainerViewController, ContainerTeamPushable {

    let teamKey: TeamKey
    private let event: Event

    // Where should we push to, when clicking the navigation bar from the top. Should be the opposite of what view sent us here
    // Ex: A EventStats VC is contexted as an Event view controller, so showDetailTeam should be true
    private let showDetailEvent: Bool
    private let showDetailTeam: Bool

    
    let myTBA: MyTBA
    
    let urlOpener: URLOpener

    // MARK: - Init

    init(teamKey: TeamKey, event: Event, myTBA: MyTBA, showDetailEvent: Bool, showDetailTeam: Bool, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.teamKey = teamKey
        self.event = event
        self.showDetailEvent = showDetailEvent
        self.showDetailTeam = showDetailTeam
        self.myTBA = myTBA
        

        self.urlOpener = urlOpener

        let summaryViewController = TeamSummaryViewController(teamKey: teamKey, event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let matchesViewController = MatchesViewController(event: event, teamKey: teamKey, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let statsViewController = TeamStatsViewController(teamKey: teamKey, event: event, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let awardsViewController = EventAwardsViewController(event: event, teamKey: teamKey, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [summaryViewController, matchesViewController, statsViewController, awardsViewController],
                   navigationTitle: "Team \(teamKey.teamNumber)",
                   navigationSubtitle: "@ \(event.friendlyNameWithYear)",
                   segmentedControlTitles: ["Summary", "Matches", "Stats", "Awards"],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        if showDetailEvent {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.eventIcon, style: .plain, target: self, action: #selector(pushEvent))
        } else if showDetailTeam {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.teamIcon, style: .plain, target: self, action: #selector(pushTeam))
        }

        summaryViewController.delegate = self
        matchesViewController.delegate = self
        awardsViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    @objc private func pushEvent() {
        let eventViewController = EventViewController(event: event, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    @objc private func pushTeam() {
        _pushTeam(attemptedToLoadTeam: false)
    }

}

extension TeamAtEventViewController: MatchesViewControllerDelegate, TeamSummaryViewControllerDelegate {

    func awardsSelected() {
        let awardsViewController = EventAwardsContainerViewController(event: event, teamKey: teamKey, myTBA: myTBA, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(awardsViewController, animated: true)
    }

    func matchSelected(_ match: Match) {
        let matchViewController = MatchViewController(match: match, teamKey: teamKey, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(matchViewController, animated: true)
    }

}

extension TeamAtEventViewController: EventAwardsViewControllerDelegate {

    func teamKeySelected(_ teamKey: TeamKey) {
        // Don't push to team@event for team we're already showing team@event for
        if self.teamKey == teamKey {
            return
        }

        let teamAtEventViewController = TeamAtEventViewController(teamKey: teamKey, event: event, myTBA: myTBA, showDetailEvent: showDetailEvent, showDetailTeam: showDetailTeam, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}
