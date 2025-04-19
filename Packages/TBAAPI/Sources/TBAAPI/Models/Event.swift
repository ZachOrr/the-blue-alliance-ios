//
//  Event.swift
//
//
//  Created by Zachary Orr on 6/10/21.
//

import Foundation
import Algorithms

public struct Event: Decodable {
    public var key: EventKey
    public var name: String
    public var eventCode: String
    public var eventTypeInt: Int
    public var eventType: EventType {
        EventType(rawValue: eventTypeInt) ?? .unlabeled
    }
    public var eventTypeString: String
    public var district: District?
    public var city: String?
    public var stateProv: String?
    public var country: String?
    public var startDate: Date
    public var endDate: Date
    public var year: Year
    public var shortName: String?
    public var week: Int?
    public var address: String?
    public var postalCode: String?
    public var gmapsPlaceID: String?
    public var gmapsURL: String?
    public var lat: Double?
    public var lng: Double?
    public var locationName: String?
    public var timezone: String?
    public var website: String?
    public var firstEventID: String?
    public var firstEventCode: String?
    public var webcasts: [Webcast]?
    public var divisionKeys: [EventKey]
    public var parentEventKey: EventKey?
    public var playoffType: PlayoffType? {
        guard let playoffTypeInt else {
            return nil
        }
        return PlayoffType(rawValue: playoffTypeInt) ?? .custom
    }
    public var playoffTypeInt: Int?
    public var playoffTypeString: String?

    enum CodingKeys: String, CodingKey {
        case key
        case name
        case eventCode = "event_code"
        case eventTypeInt = "event_type"
        case district
        case city
        case stateProv = "state_prov"
        case country
        case startDate = "start_date"
        case endDate = "end_date"
        case year
        case shortName = "short_name"
        case eventTypeString = "event_type_string"
        case week
        case address
        case postalCode = "postal_code"
        case gmapsPlaceID = "gmaps_place_id"
        case gmapsURL = "gmaps_url"
        case lat
        case lng
        case locationName = "location_name"
        case timezone
        case website
        case firstEventID = "first_event_id"
        case firstEventCode = "first_event_code"
        case webcasts
        case divisionKeys = "division_keys"
        case parentEventKey = "parent_event_key"
        case playoffTypeInt = "playoff_type"
        case playoffTypeString = "playoff_type_string"
    }
}

public enum EventType: Int, CaseIterable, Hashable {
    case regional = 0
    case district = 1
    case districtChampionship = 2
    case championshipDivision = 3
    case championshipFinals = 4
    case districtChampionshipDivision = 5
    case festivalOfChampions = 6
    case remote = 7
    case offseason = 99
    case preseason = 100
    case unlabeled = -1
}

public enum PlayoffType: Int, Sendable {
    // Standard Brackets
    case bracket16Team = 1
    case bracket8Team = 0
    case bracket4Team = 2
    case bracket2Team = 9

    // 2015 is special
    case avgScore8Team = 3

    // Round Robin
    case roundRobin6Team = 4

    // Double Elimination Bracket
    // The legacy style is just a basic internet bracket
    case legacyDoubleElim8Team = 5
    // The "regular" style is the one that FIRST plans to trial for the 2023 season
    // https://www.firstinspires.org/robotics/frc/blog/2022-timeout-and-playoff-tournament-updates
    case doubleElim8Team = 10
    // The bracket used for districts with four divisions
    case doubleElim4Team = 11

    // Festival of Champions
    case bo5Finals = 6

    case bo3Finals = 7

    case custom = 8

    public var playoffTypeString: String {
        switch self {
        case .bracket16Team:
            return "Elimination Bracket (16 Alliances)"
        case .bracket8Team:
            return "Elimination Bracket (8 Alliances)"
        case .bracket4Team:
            return "Elimination Bracket (4 Alliances)"
        case .bracket2Team:
            return "Elimination Bracket (2 Alliances)"
        case .avgScore8Team:
            return "Average Score (8 Alliances)"
        case .roundRobin6Team:
            return "Round Robin (6 Alliances)"
        case .legacyDoubleElim8Team:
            return "Legacy Double Elimination Bracket (8 Alliances)"
        case .doubleElim8Team:
            return "Double Elimination Bracket (8 Alliances)"
        case .doubleElim4Team:
            return "Double Elimination Bracket (4 Alliances)"
        case .bo5Finals:
            return "Best of 5 Finals"
        case .bo3Finals:
            return "Best of 3 Finals"
        case .custom:
            return "Custom"
        }
    }

    private static let doubleElimTypes: [PlayoffType] = [.legacyDoubleElim8Team, .doubleElim8Team, .doubleElim4Team]

    private static let bracketTypes: [PlayoffType] = [.bracket2Team, .bracket4Team, .bracket8Team, .bracket16Team]

    var isDoubleElimType: Bool {
        PlayoffType.doubleElimTypes.contains(self)
    }

    var isBracketType: Bool {
        PlayoffType.bracketTypes.contains(self)
    }
}

/**
 EventWeek represents the Week for the Week selector. It groups events by week,
 Preseasons, Offseasons by month, CMP events by CMP, and otherwise events of the
 same type together.
 */
/*
public enum EventWeek: Hashable {
    case eventType(EventType, String) // event_type, event_type_string
    // Note: Represented as a Double because 2016 has a Week 0.5 event
    case week(Double) // This is the 1-indexed Week number
    // Note: index will be empty in the case of getting an Event.eventWeek
    // The index will come back when getting [Event].eventsByWeek()
    // Otherwise, use Event.eventWeek(cmpIndex:) if the index is known
    case cmp(EventKey, Int?, String?) // (event_code, index, city)
    case offseason(Int) // month, 1-12
    case other

    public var description: String {
        switch self {
        case .eventType(_, let eventTypeString):
            return eventTypeString
        case .week(let week):
            if let week = Int(exactly: week) {
                return "Week \(week)"
            }
            return "Week \(week)"
        case .cmp(_, let index, let city):
            if let _ = index, let city {
                return "FIRST Championship - \(city)"
            } else {
                return "FIRST Championship"
            }
        case .offseason(let month):
            let monthSymbol = Calendar.current.standaloneMonthSymbols[month - 1]
            return "\(monthSymbol) Offseason"
        case .other:
            return "Other"
        }
    }

    public var weekString: String? {
        guard case .week(let week) = self else {
            return nil
        }
        if let week = Int(exactly: week) {
            return "Week \(week)"
        }
        return "Week \(week)"
    }
}
*/
/*
extension Array where Element == Event {
    private var sortedCMPKeys: [EventKey] {
        return self.filter(\.isCMPFinals).sorted(using: KeyPathComparator(\.startDate)).map(\.key)
    }

    public func nextOrFirstEvent() -> Event? {
        let sortedEvents = self.sorted(using: [KeyPathComparator(\.startDate), KeyPathComparator(\.endDate)])
        let firstEvent = sortedEvents.first
        guard firstEvent?.year == Calendar.current.year else {
            return firstEvent
        }
        return sortedEvents.first { event in
            event.endDate > Date().startOfDay()
        } ?? firstEvent
    }

    public func eventsByWeek() -> [EventWeek: [Event]] {
        let sortedCMPKeys = sortedCMPKeys
        guard sortedCMPKeys.count > 1 else {
            return self.grouped(by: { $0.eventWeek })
        }
        return self.grouped { event in
            if let cmpIndex = sortedCMPKeys.firstIndex(of: event.key) {
                return event.eventWeek(cmpIndex: cmpIndex)
            }
            return event.eventWeek
        }
    }
}
*/
/*
extension Event {

    public var eventWeek: EventWeek {
        if let week = week {
            /**
             * Special cases for 2016:
             * Week 1 is actually Week 0.5, eveything else is one less
             * See http://www.usfirst.org/roboticsprograms/frc/blog-The-Palmetto-Regional
             */
            if year == 2016, week == 0 {
                return .week(0.5)
            }
            return .week(Double(week + 1))
        } else if isChampionshipEvent {
            return .cmp(parentEventKey ?? key, nil, city)
        } else if isOffseason {
            return .offseason(startDate.month)
        }
        return .eventType(eventType, eventTypeString)
    }

    fileprivate func eventWeek(cmpIndex: Int) -> EventWeek {
        let eventWeek = eventWeek
        switch eventWeek {
        case .cmp(let key, let index, let city) where index == nil:
            return .cmp(key, cmpIndex, city)
        default:
            return eventWeek
        }
    }

    public var startMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: startDate)
    }

    public var isDistrictChampionshipEvent: Bool {
        return isDistrictChampionship || isDistrictChampionshipDivision
    }

    public var isDistrictChampionshipDivision: Bool {
        return eventType == .districtChampionshipDivision
    }

    public var isDistrictChampionship: Bool {
        return eventType == .districtChampionship
    }

    public var isChampionshipEvent: Bool {
        return isCMPDivision || isCMPFinals
    }

    public var isCMPDivision: Bool {
        return eventType == .championshipDivision
    }

    public var isCMPFinals: Bool {
        return eventType == .championshipFinals
    }

    public var isOffseason: Bool {
        eventType == .offseason
    }

    /**
     hybridType is used a mechanism for sorting Events properly in lists. It use a variety
     of event data to kinda "move around" events in our data model to get groups/order right.
     Note - hybrid type is ONLY safe to sort by for events within the same year.
     Sorting by hybrid type for events across years will put events together roughly by their types,
     but not necessairly their true sorts (see Comparable for a true sort)
     */
    // TODO: Convert hybridType into enum
    public var hybridType: String {
        // Group districts together, group district CMPs together
        if isDistrictChampionshipEvent {
            // Due to how DCMP divisions come *after* everything else if sorted by default
            // This is a bit of a hack to get them to show up before DCMPs
            // Future-proofing - group DCMP divisions together based on district
            if isDistrictChampionshipDivision, let district = district {
                return "\(EventType.districtChampionship.rawValue)..\(district.abbreviation).dcmpd"
            }
            return "\(eventType).dcmp"
        } else if let district = district, !isDistrictChampionshipEvent {
            return "\(eventType).\(district.abbreviation)"
        } else if isOffseason {
            // Group offseason events together by month
            // Pad our month with a leading `0` - this is so we can have "99.9" < "99.11"
            // (September Offseason to be sorted before November Offseason). Swift will compare
            // each character's hex value one-by-one, which means we'll fail at "9" < "1".
            let monthString = String(format: "%02d", startDate.month)
            return "\(eventType).\(monthString)"
        }
        return "\(eventType)"

    }

    public var displayShortName: String {
        let fallbackName = name.isEmpty ? key : name
        guard let shortName = shortName else {
            return fallbackName
        }
        return shortName.isEmpty ? fallbackName : shortName
    }

    public var displayLocation: String? {
        let location = [city, stateProv, country].compactMap { dateComponent in
            guard let dateComponent else {
                return nil
            }
            return dateComponent.isEmpty ? nil : dateComponent
        }.joined(separator: ", ")
        return location.isEmpty ? nil : location
    }

    public var displayDates: String {
        let calendar = Calendar.current

        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "MMM dd"

        let longDateFormatter = DateFormatter()
        longDateFormatter.dateFormat = "MMM dd, y"

        if startDate == endDate {
            return shortDateFormatter.string(from: endDate)
        } else if calendar.component(.year, from: startDate) == calendar.component(.year, from: endDate) {
            return "\(shortDateFormatter.string(from: startDate)) to \(shortDateFormatter.string(from: endDate))"
        }
        return "\(shortDateFormatter.string(from: startDate)) to \(longDateFormatter.string(from: endDate))"
    }

    /**
     If the event is currently going, based on it's start and end dates.
     */
    public var isHappeningNow: Bool {
        return Date().isBetween(date: startDate, andDate: endDate.endOfDay())
    }
}
*/
/*
extension EventType: Comparable {
    public static func < (lhs: EventType, rhs: EventType) -> Bool {
        // Float preseasons to the top
        if lhs == .preseason || rhs == .preseason {
            return lhs == .preseason
        }
        // Drop unlabeled to the bottom
        if lhs == .unlabeled || rhs == .unlabeled {
            return rhs == .unlabeled
        }
        // Note to Zach: I got tired of finding the right way to do this -
        // we're going with this way
        // Put Remote up with Regional/District
        // Put DCMP Divisions before DCMP
        let adjustValue: ((EventType) -> Double) = { eventType in
            if eventType == .remote {
                return 1.1
            }
            if eventType == .districtChampionshipDivision {
                return 1.2
            }
            return Double(eventType.rawValue)
        }
        let adjustedLHSValue = adjustValue(lhs)
        let adjustedRHSValue = adjustValue(rhs)
        return adjustedLHSValue < adjustedRHSValue
    }
}
*/
/*
extension EventWeek: Comparable {
    public static func <(lhs: EventWeek, rhs: EventWeek) -> Bool {
        switch lhs {
        case .other:
            return false
        case .offseason(let lhsMonth) where lhsMonth == 1:
            // Weirdly, float January offseasons to the top
            // Noting: This is probably wrong, since any January offseason would
            // be happening in the ~3-7 days before Kickoff, so technically these events
            // would be previous seson events. But that's not how we would return them from the API.
            return true
        case .eventType(.preseason, _):
            switch rhs {
            case .offseason(let rhsMonth) where rhsMonth == 1:
                return false
            default:
                return true
            }
        case .eventType(let lhsEventType, _):
            switch rhs {
            case .eventType(let rhsEventType, _):
                return lhsEventType < rhsEventType
            case .offseason(_):
                return true
            default:
                return false
            }
        case .week(let lhsWeek):
            switch rhs {
            case .offseason(let rhsMonth) where rhsMonth == 1:
                return false
            case .eventType(.preseason, _):
                return false
            case .week(let rhsWeek):
                return lhsWeek < rhsWeek
            default:
                return true
            }
        case .cmp(_, let lhsIndex, _):
            switch rhs {
            case .cmp(_, let rhsIndex, _):
                if let lhsIndex, let rhsIndex {
                    return lhsIndex < rhsIndex
                }
                return false
            case .eventType(.festivalOfChampions, _), .offseason(_), .other:
                return true
            default:
                return false
            }
        case .offseason(let lhsMonth):
            switch rhs {
            case .offseason(let rhsMonth):
                return lhsMonth < rhsMonth
            case .other:
                return true
            default:
                return false
            }
        }
    }
}
*/
