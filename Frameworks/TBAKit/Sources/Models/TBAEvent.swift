//
//  TBAEvent.swift
//  TBAEvent
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAEvent {
    public var key: String
    public var name: String
    public var eventCode: String
    public var eventType: Int
    public var district: TBADistrict?
    public var city: String?
    public var stateProv: String?
    public var country: String?
    public var startDate: Date
    public var endDate: Date
    public var year: Int
    public var shortName: String?
    public var eventTypeString: String
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
    public var webcasts: [TBAWebcast]?
    public var divisionKeys: [String]
    public var parentEventKey: String?
    public var playoffType: Int?
    public var playoffTypeString: String?
    
    /*
    public init(key: String, name: String, eventCode: String, eventType: Int, district: TBADistrict? = nil, city: String? = nil, stateProv: String? = nil, country: String? = nil, startDate: Date, endDate: Date, year: Int, shortName: String? = nil, eventTypeString: String, week: Int? = nil, address: String? = nil, postalCode: String? = nil, gmapsPlaceID: String? = nil, gmapsURL: String? = nil, lat: Double? = nil, lng: Double? = nil, locationName: String? = nil, timezone: String? = nil, website: String? = nil, firstEventID: String? = nil, firstEventCode: String? = nil, webcasts: [TBAWebcast]? = nil, divisionKeys: [String], parentEventKey: String? = nil, playoffType: Int? = nil, playoffTypeString: String? = nil) {
        self.key = key
        self.name = name
        self.eventCode = eventCode
        self.eventType = eventType
        self.district = district
        self.city = city
        self.stateProv = stateProv
        self.country = country
        self.startDate = startDate
        self.endDate = endDate
        self.year = year
        self.shortName = shortName
        self.eventTypeString = eventTypeString
        self.week = week
        self.address = address
        self.postalCode = postalCode
        self.gmapsPlaceID = gmapsPlaceID
        self.gmapsURL = gmapsURL
        self.lat = lat
        self.lng = lng
        self.locationName = locationName
        self.timezone = timezone
        self.website = website
        self.firstEventID = firstEventID
        self.firstEventCode = firstEventCode
        self.webcasts = webcasts
        self.divisionKeys = divisionKeys
        self.parentEventKey = parentEventKey
        self.playoffType = playoffType
        self.playoffTypeString = playoffTypeString
    }

    init?(json: [String: Any]) {
        // Required: key, name, eventCode, eventType startDate, endDate, year
        guard let key = json["key"] as? String else {
            return nil
        }
        self.key = key

        guard let name = json["name"] as? String else {
            return nil
        }
        self.name = name
        
        guard let eventCode = json["event_code"] as? String else {
            return nil
        }
        self.eventCode = eventCode
        
        guard let eventType = json["event_type"] as? Int else {
            return nil
        }
        self.eventType = eventType

        if let districtJSON = json["district"] as? [String: Any] {
            self.district = TBADistrict(json: districtJSON)
        }

        self.city = json["city"] as? String
        self.stateProv = json["state_prov"] as? String
        self.country = json["country"] as? String

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let startDateString = json["start_date"] as? String, let startDate = dateFormatter.date(from: startDateString) else {
            return nil
        }
        self.startDate = startDate

        guard let endDateString = json["end_date"] as? String, let endDate = dateFormatter.date(from: endDateString) else {
            return nil
        }
        self.endDate = endDate
        
        guard let year = json["year"] as? Int else {
            return nil
        }
        self.year = year

        self.shortName = json["short_name"] as? String

        guard let eventTypeString = json["event_type_string"] as? String else {
            return nil
        }
        self.eventTypeString = eventTypeString

        self.week = json["week"] as? Int
        self.address = json["address"] as? String
        self.postalCode = json["postal_code"] as? String
        self.gmapsPlaceID = json["gmaps_place_id"] as? String
        self.gmapsURL = json["gmaps_url"] as? String
        self.lat = json["lat"] as? Double
        self.lng = json["lng"] as? Double
        self.locationName = json["location_name"] as? String
        self.timezone = json["timezone"] as? String
        self.website = json["website"] as? String
        self.firstEventID = json["first_event_id"] as? String
        self.firstEventCode = json["first_event_code"] as? String

        var webcasts: [TBAWebcast] = []
        if let webcastJSON = json["webcasts"] as? [[String: Any]] {
            for result in webcastJSON {
                if let webcast = TBAWebcast(json: result) {
                    webcasts.append(webcast)
                }
            }
        }
        self.webcasts = webcasts

        // API should always return us an empty array if there are no division keys
        // ...but just to be safe...
        if let divisionKeys = json["division_keys"] as? [String] {
            self.divisionKeys = divisionKeys
        } else {
            self.divisionKeys = []
        }

        // Currently checking these for nulls since non-2017 events don't support
        // Might be able to remove after some migrations
        if let parentEventKey = json["parent_event_key"] as? String {
            self.parentEventKey = parentEventKey
        }
        if let playoffType = json["playoff_type"] as? Int {
            self.playoffType = playoffType
        }
        if let playoffTypeString = json["playoff_type_string"] as? String {
            self.playoffTypeString = playoffTypeString
        }
    }
    */

}

extension TBAEvent: Decodable {
    enum CodingKeys: String, CodingKey {
        case key
        case name
        case eventCode = "event_code"
        case eventType = "event_type"
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
        case playoffType = "playoff_type"
        case playoffTypeString = "playoff_type_string"
    }
}
