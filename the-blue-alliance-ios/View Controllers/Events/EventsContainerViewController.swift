import CoreData

import Foundation
import MyTBAKit
import TBAKit
import UIKit

class EventsContainerViewController: ContainerViewController {


    private let myTBA: MyTBA

    private let urlOpener: URLOpener

    private(set) var year: Int
    private(set) var eventsViewController: WeekEventsViewController

    // MARK: - Init

    init(myTBA: MyTBA, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.myTBA = myTBA
        
        self.urlOpener = urlOpener

        year = 2019
        eventsViewController = WeekEventsViewController(year: year, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [eventsViewController],
                   navigationTitle: EventsContainerViewController.eventsTitle(eventsViewController.weekEvent),
                   navigationSubtitle: ContainerViewController.yearSubtitle(year),
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        title = "Events"
        tabBarItem.image = UIImage.eventIcon

        navigationTitleDelegate = self
        eventsViewController.delegate = self
        eventsViewController.weekEventsDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private static func eventsTitle(_ event: Event?) -> String {
        if let event = event {
            return "\(event.weekString) Events"
        } else {
            return "---- Events"
        }
    }

    private func updateInterface() {
        navigationTitle = EventsContainerViewController.eventsTitle(eventsViewController.weekEvent)
        navigationSubtitle = ContainerViewController.yearSubtitle(year)
    }

}

extension EventsContainerViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        let yearSelectViewController = YearSelectViewController(year: year, years: Array(1992...2019).reversed(), week: eventsViewController.weekEvent, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        yearSelectViewController.delegate = self

        let nav = UINavigationController(rootViewController: yearSelectViewController)
        nav.modalPresentationStyle = .formSheet
        navigationController?.present(nav, animated: true, completion: nil)
    }

}

extension EventsContainerViewController: YearSelectViewControllerDelegate {

    func weekEventSelected(_ weekEvent: Event) {
        year = weekEvent.year!.intValue
        eventsViewController.weekEvent = weekEvent
    }

}

extension EventsContainerViewController: WeekEventsDelegate {

    func weekEventUpdated() {
        updateInterface()
    }

}

extension EventsContainerViewController: EventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        // Show detail wrapped in a UINavigationController for our split view controller
        let eventViewController = EventViewController(event: event, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let nav = UINavigationController(rootViewController: eventViewController)
        navigationController?.showDetailViewController(nav, sender: nil)
    }

}
