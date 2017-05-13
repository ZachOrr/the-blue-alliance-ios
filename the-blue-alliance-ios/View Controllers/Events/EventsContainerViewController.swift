//
//  EventsContainerViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/18/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import TBAKit

let EventsEmbed = "EventsEmbed"
let EventSegue = "EventSegue"
let SelectWeekSegue = "SelectWeekSegue"
let SelectYearSegue = "SelectYearSegue"

class EventsContainerViewController: ContainerViewController {
    internal var eventsViewController: EventsTableViewController?
    @IBOutlet internal var eventsView: UIView?
    @IBOutlet internal var weeksButton: UIBarButtonItem?
    
    internal var weeks: [Event] = []
    internal var maxYear: Int?
    internal var week: Event? {
        didSet {
            eventsViewController?.weekEvent = week

            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }
    internal var year: Int? {
        didSet {
            eventsViewController?.year = year
            // Year changed - remove our previously selected week
            week = nil
            weeks = []
            
            setupWeeks()
            
            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        let year = UserDefaults.standard.integer(forKey: StatusConstants.currentSeasonKey)
        if year != 0 {
            self.year = year
        }
        
        let maxYear = UserDefaults.standard.integer(forKey: StatusConstants.maxSeasonKey)
        if maxYear != 0 {
            self.maxYear = maxYear
        }
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [eventsViewController!]
        containerViews = [eventsView!]
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.fetchedTBAStatus),
                                               name: Notification.Name(kFetchedTBAStatus),
                                               object: nil)
        
        if year != nil {
            setupWeeks()
        }

        updateInterface()
    }
    
    // MARK: - Private Methods

    func updateInterface() {
        if let week = week {
            navigationTitleLabel?.text = "\(week.weekString) Events"
        } else {
            navigationTitleLabel?.text = "---- Events"
        }
        
        if let year = year {
            navigationDetailLabel?.text = "▾ \(year)"
        } else {
            navigationDetailLabel?.text = "▾ ----"
        }
        
        if !weeks.isEmpty {
            weeksButton?.title = "Weeks"
        } else {
            weeksButton?.title = "----"
        }
        
        if year == nil && week == nil {
            // Show loading
        } else {
            // Hide loading
        }
    }
    
    func setupCurrentSeasonWeek() {
        guard let year = year else {
            showNoDataView(with: "No year selected")
            return
        }

        // Fetch all events where endDate is today or after today
        let date = Date()
        // Remove time from date - we only care about the day
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        
        // Conversion stuff because Core Data still uses NSDates
        guard let swiftDate = Calendar.current.date(from: components) else {
            showErrorAlert(with: "Unable to setup current season week - datetime conversion failed")
            return
        }
        let coreDataDate = NSDate(timeIntervalSince1970: swiftDate.timeIntervalSince1970)
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Event.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "year == %ld && endDate >= %@ && eventType != %ld", year, coreDataDate, EventType.championshipDivision.rawValue)
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: true)]
        
        guard let events = try? persistentContainer?.viewContext.fetch(fetchRequest) as! [Event] else {
            showErrorAlert(with: "Unable to setup current season week - fetch request failed")
            return
        }
        
        // TODO: Need to know if we have no events OR if we just don't have any more events this year
        // If we don't have any more events this year *and* year != maxYear... just bump our year to maxYear and refresh
        // Need to consider how this works if you switch to the current year in like December... we don't wanna bump
        if !events.isEmpty {
            self.week = events.first
        } else {
            showErrorAlert(with: "Unable to setup current season week - no events for year")
        }
    }
    
    func setupWeeks() {
        guard let year = year else {
            showNoDataView(with: "No year selected")
            return
        }
        
        // Don't re-setup weeks if we're in the same year as we already have... (ex: a refresh)
        // TODO: This doesn't handle if a week is removed from our backing data store... that will break this
        if let week = week, year == Int(week.year) {
            return
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Event.fetchRequest()
        // Filter out CMP divisions
        fetchRequest.predicate = NSPredicate(format: "year == %ld && eventType != %ld", year, EventType.championshipDivision.rawValue)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "week", ascending: true), NSSortDescriptor(key: "eventType", ascending: true), NSSortDescriptor(key: "endDate", ascending: true)]
        
        guard let events = try? persistentContainer?.viewContext.fetch(fetchRequest) as! [Event] else {
            showErrorAlert(with: "Unable to setup weeks - fetch request failed")
            return
        }
        // TODO: Need to know if we have no events OR if we just don't have any more events this year
        if events.isEmpty {
            guard let eventsViewController = eventsViewController else {
                showErrorAlert(with: "Unable to setup weeks - eventsViewController not instantiated")
                return
            }
            // Initial load of events for eventsVC
            if eventsViewController.shouldRefresh() {
                eventsViewController.refresh()
            }
            return
        }
        
        var handledWeeks: Set<Int> = []
        var handledTypes: Set<Int> = []
        self.weeks = Array(events.flatMap({ (event) -> Event? in
            let eventType = Int(event.eventType)
            if let week = event.week {
                // Make sure each week only shows up once
                if handledWeeks.contains(week.intValue) {
                    return nil
                }
                handledWeeks.insert(week.intValue)
                return event
            } else if eventType == EventType.championshipFinals.rawValue {
                // Always add all CMP finals
                return event
            } else {
                // Make sure we only have preseason, offseason, unlabeled once
                if handledTypes.contains(eventType) {
                    return nil
                }
                handledTypes.insert(eventType)
                return event
            }
        })).sorted()
        
        if year == Calendar.current.year && week == nil {
            // If it's the current year, setup the current week for this year
            setupCurrentSeasonWeek()
        } else {
            // Otherwise, default to the first week for this year
            if let firstWeek = self.weeks.first {
                week = firstWeek
            } else {
                showErrorAlert(with: "Unable to setup weeks - no events for selected year")
            }
        }
        
        DispatchQueue.main.async {
            self.updateInterface()
        }
    }
    
    // MARK: - Observers
    
    func fetchedTBAStatus(notification: NSNotification) {
        guard let status = notification.object as? TBAStatus else {
            showErrorAlert(with: "TBA status fetch failed")
            return
        }
        if year == nil {
            year = Int(status.currentSeason)
        }
        if maxYear == nil {
            maxYear = Int(status.maxSeason)
        }
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SelectYearSegue && (maxYear == nil || year == nil) {
            return false
        } else if identifier == SelectWeekSegue && (weeks.isEmpty || week == nil) {
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SelectYearSegue || segue.identifier == SelectWeekSegue {
            let nav = segue.destination as! UINavigationController
            
            if segue.identifier == SelectYearSegue {
                let selectTableViewController = SelectTableViewController<Int>()
                selectTableViewController.title = "Select Year"
                selectTableViewController.current = year
                selectTableViewController.options = Array(1992...maxYear!).reversed()
                selectTableViewController.optionSelected = { year in
                    self.year = year
                }
                selectTableViewController.optionString = { year in
                    return String(year)
                }
                nav.viewControllers = [selectTableViewController]
            } else {
                let selectTableViewController = SelectTableViewController<Event>()
                selectTableViewController.title = "Select Week"
                selectTableViewController.current = week!
                selectTableViewController.options = weeks
                selectTableViewController.optionSelected = { week in
                    self.week = week
                }
                selectTableViewController.optionString = { week in
                    return week.weekString
                }
                nav.viewControllers = [selectTableViewController]
            }
        } else if segue.identifier == EventSegue {
            let eventViewController = (segue.destination as! UINavigationController).topViewController as! EventViewController
            eventViewController.event = sender as? Event
            // TODO: Find a way to pass these down automagically like we did in the Obj-C version
            eventViewController.persistentContainer = persistentContainer
        } else if segue.identifier == EventsEmbed {
            eventsViewController = segue.destination as? EventsTableViewController
            if !weeks.isEmpty {
                eventsViewController!.weekEvent = weeks.first
            } else {
                // TODO: Show loading that we're fetching weeks...
            }
            eventsViewController!.year = year
            
            eventsViewController!.eventsFetched = {
                self.setupWeeks()
            }
            eventsViewController!.eventSelected = { event in
                self.performSegue(withIdentifier: EventSegue, sender: event)
            }
        }
    }
    
}
