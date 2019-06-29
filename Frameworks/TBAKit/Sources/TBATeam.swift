import Combine
import Foundation

public struct TBATeam: TBAModel {
    public var key: String
    public var teamNumber: Int
    public var nickname: String?
    public var name: String
    public var city: String?
    public var stateProv: String?
    public var country: String?
    public var address: String?
    public var postalCode: String?
    public var gmapsPlaceID: String?
    public var gmapsURL: String?
    public var lat: Double?
    public var lng: Double?
    public var locationName: String?
    public var website: String?
    public var rookieYear: Int
    public var homeChampionship: [String: String]?

    public init(key: String, teamNumber: Int, nickname: String? = nil, name: String, city: String? = nil, stateProv: String? = nil, country: String? = nil, address: String? = nil, postalCode: String? = nil, gmapsPlaceID: String? = nil, gmapsURL: String? = nil, lat: Double? = nil, lng: Double? = nil, locationName: String? = nil, website: String? = nil, rookieYear: Int, homeChampionship: [String: String]? = nil) {
        self.key = key
        self.teamNumber = teamNumber
        self.nickname = nickname
        self.name = name
        self.city = city
        self.stateProv = stateProv
        self.country = country
        self.address = address
        self.postalCode = postalCode
        self.gmapsPlaceID = gmapsPlaceID
        self.gmapsURL = gmapsURL
        self.lat = lat
        self.lng = lng
        self.locationName = locationName
        self.website = website
        self.rookieYear = rookieYear
        self.homeChampionship = homeChampionship
    }

    init?(json: [String: Any]) {
        // Required: key, name, teamNumber, rookieYear
        guard let key = json["key"] as? String else {
            return nil
        }
        self.key = key
        
        guard let name = json["name"] as? String else {
            return nil
        }
        self.name = name
        
        guard let teamNumber = json["team_number"] as? Int else {
            return nil
        }
        self.teamNumber = teamNumber
        
        guard let rookieYear = json["rookie_year"] as? Int else {
            return nil
        }
        self.rookieYear = rookieYear
        
        self.address = json["address"] as? String
        self.city = json["city"] as? String
        self.country = json["country"] as? String
        self.gmapsPlaceID = json["gmaps_place_id"] as? String
        self.gmapsURL = json["gmaps_url"] as? String
        self.homeChampionship = json["home_championship"] as? [String: String]
        self.lat = json["lat"] as? Double
        self.lng = json["lng"] as? Double
        self.locationName = json["location_name"] as? String
        self.nickname = json["nickname"] as? String
        self.postalCode = json["postal_code"] as? String
        self.stateProv = json["state_prov"] as? String
        self.website = json["website"] as? String
    }

}

public struct TBARobot: TBAModel {
    public var key: String
    public var name: String
    public var teamKey: String
    public var year: Int

    public init(key: String, name: String, teamKey: String, year: Int) {
        self.key = key
        self.name = name
        self.teamKey = teamKey
        self.year = year
    }

    init?(json: [String: Any]) {
        // Required: key, name, teamKey, year
        guard let key = json["key"] as? String else {
            return nil
        }
        self.key = key

        guard let name = json["robot_name"] as? String else {
            return nil
        }
        self.name = name

        guard let teamKey = json["team_key"] as? String else {
            return nil
        }
        self.teamKey = teamKey

        guard let year = json["year"] as? Int else {
            return nil
        }
        self.year = year
    }

}

public struct TBAEventStatus: TBAModel {
    
    public var teamKey: String
    public var eventKey: String
    
    public var qual: TBAEventStatusQual?
    public var alliance: TBAEventStatusAlliance?
    public var playoff: TBAAllianceStatus?
    
    public var allianceStatusString: String?
    public var playoffStatusString: String?
    public var overallStatusString: String?
    
    public var nextMatchKey: String?
    public var lastMatchKey: String?

    public init(teamKey: String, eventKey: String, qual: TBAEventStatusQual? = nil, alliance: TBAEventStatusAlliance? = nil, playoff: TBAAllianceStatus? = nil, allianceStatusString: String? = nil, playoffStatusString: String? = nil, overallStatusString: String? = nil, nextMatchKey: String? = nil, lastMatchKey: String? = nil) {
        self.teamKey = teamKey
        self.eventKey = eventKey

        self.qual = qual
        self.alliance = alliance
        self.playoff = playoff

        self.allianceStatusString = allianceStatusString
        self.playoffStatusString = playoffStatusString
        self.overallStatusString = overallStatusString

        self.nextMatchKey = nextMatchKey
        self.lastMatchKey = lastMatchKey
    }

    init?(json: [String: Any]) {
        // Required: teamKey, eventKey (as passed in by JSON manually)
        guard let teamKey = json["team_key"] as? String else {
            return nil
        }
        self.teamKey = teamKey

        guard let eventKey = json["event_key"] as? String else {
            return nil
        }
        self.eventKey = eventKey
        
        if let qualJSON = json["qual"] as? [String: Any] {
            self.qual = TBAEventStatusQual(json: qualJSON)
        }
        
        if let allianceJSON = json["alliance"] as? [String: Any] {
            self.alliance = TBAEventStatusAlliance(json: allianceJSON)
        }
        
        if let playoffJSON = json["playoff"] as? [String: Any] {
            self.playoff = TBAAllianceStatus(json: playoffJSON)
        }

        self.allianceStatusString = json["alliance_status_str"] as? String
        self.playoffStatusString = json["playoff_status_str"] as? String
        self.overallStatusString = json["overall_status_str"] as? String
        self.nextMatchKey = json["next_match_key"] as? String
        self.lastMatchKey = json["last_match_key"] as? String
    }
    
}

public struct TBAEventStatusQual: TBAModel {
    
    public var numTeams: Int?
    public var status: String?
    public var ranking: TBAEventRanking?
    public var sortOrder: [TBAEventRankingSortOrder]?

    public init(numTeams: Int? = nil, status: String? = nil, ranking: TBAEventRanking? = nil, sortOrder: [TBAEventRankingSortOrder]? = nil) {
        self.numTeams = numTeams
        self.status = status
        self.ranking = ranking
        self.sortOrder = sortOrder
    }

    init?(json: [String: Any]) {
        self.numTeams = json["num_teams"] as? Int
        self.status = json["status"] as? String
        
        if let rankingJSON = json["ranking"] as? [String: Any] {
            self.ranking = TBAEventRanking(json: rankingJSON)
        }
        
        if let sortOrdersJSON = json["sort_order_info"] as? [[String: Any]] {
            self.sortOrder = sortOrdersJSON.compactMap({ (sortOrderJSON) -> TBAEventRankingSortOrder? in
                return TBAEventRankingSortOrder(json: sortOrderJSON)
            })
        }
    }
    
}

public struct TBAEventStatusAlliance: TBAModel {
    
    public var number: Int
    public var pick: Int
    public var name: String?
    public var backup: TBAAllianceBackup?

    public init(number: Int, pick: Int, name: String? = nil, backup: TBAAllianceBackup? = nil) {
        self.number = number
        self.pick = pick
        self.name = name
        self.backup = backup
    }

    init?(json: [String: Any]) {
        // Required: number, pick
        guard let number = json["number"] as? Int else {
            return nil
        }
        self.number = number
        
        guard let pick = json["pick"] as? Int else {
            return nil
        }
        self.pick = pick
        
        self.name = json["name"] as? String
        
        if let backupJSON = json["backup"] as? [String: Any] {
            self.backup = TBAAllianceBackup(json: backupJSON)
        }
    }

}

public struct TBAMedia: TBAModel {
    
    public var key: String?
    public var type: String
    public var foreignKey: String?
    public var details: [String: Any]?
    public var preferred: Bool?
    public var directURL: String?
    public var viewURL: String?

    public init(key: String? = nil, type: String, foreignKey: String? = nil, details: [String: Any]? = nil, preferred: Bool? = nil, directURL: String? = nil, viewURL: String? = nil) {
        self.key = key
        self.type = type
        self.foreignKey = foreignKey
        self.details = details
        self.preferred = preferred
        self.directURL = directURL
        self.viewURL = viewURL
    }

    init?(json: [String: Any]) {
        // Required: type
        self.key = json["key"] as? String
        
        guard let type = json["type"] as? String else {
            return nil
        }
        self.type = type

        self.foreignKey = json["foreign_key"] as? String
        self.details = json["details"] as? [String: Any]
        self.preferred = json["preferred"] as? Bool
        self.directURL = json["direct_url"] as? String
        self.viewURL = json["view_url"] as? String
    }
    
}

extension TBAKit {

    @discardableResult
    public func fetchTeams(page: Int, year: Int? = nil) -> AnyPublisher<([TBATeam], Bool, URLResponse), Error> {
        var method = "teams"
        if let year = year {
            method = "\(method)/\(year)"
        }
        method = "\(method)/\(page)"
        return callArray(method: method)
    }

    @discardableResult
    public func fetchTeam(key: String) -> AnyPublisher<(TBATeam?, Bool, URLResponse), Error> {
        let method = "team/\(key)"
        return callObject(method: method)
    }

    @discardableResult
    public func fetchTeamYearsParticipated(key: String) -> AnyPublisher<([Int], Bool, URLResponse), Error> {
        let method = "team/\(key)/years_participated"
        return callArray(method: method).tryMap { (array, unmodified, response) -> ([Int], Bool, URLResponse) in
            if let years = array as? [Int] {
                return (years, unmodified, response)
            } else {
                throw APIError.error("Unexpected response from server.") as Error
            }
        }.eraseToAnyPublisher()
    }

    @discardableResult
    public func fetchTeamDistricts(key: String) -> AnyPublisher<([TBADistrict], Bool, URLResponse), Error> {
        let method = "team/\(key)/districts"
        return callArray(method: method)
    }

    @discardableResult
    public func fetchTeamRobots(key: String) -> AnyPublisher<([TBARobot], Bool, URLResponse), Error> {
        let method = "team/\(key)/robots"
        return callArray(method: method)
    }

    @discardableResult
    public func fetchTeamEvents(key: String, year: Int? = nil) -> AnyPublisher<([TBAEvent], Bool, URLResponse), Error> {
        var method = "team/\(key)/events"
        if let year = year {
            method = "\(method)/\(year)"
        }
        return callArray(method: method)
    }

    @discardableResult
    public func fetchTeamStatuses(key: String, year: Int) -> AnyPublisher<([TBAEventStatus], Bool, URLResponse), Error> {
        let method = "team/\(key)/events/\(year)/statuses"
        return callDictionary(method: method).map { (dictionary, unmodified, response) -> ([TBAEventStatus], Bool, URLResponse) in
            return (dictionary.compactMap({ (eventKey, statusJSON) -> TBAEventStatus? in
                // Add teamKey/eventKey to statusJSON
                guard var json = statusJSON as? [String: Any] else {
                    return nil
                }
                json["team_key"] = key
                json["event_key"] = eventKey

                return TBAEventStatus(json: json)
            }), unmodified, response)
        }.eraseToAnyPublisher()
    }

    @discardableResult
    public func fetchTeamMatches(key: String, eventKey: String) -> AnyPublisher<([TBAMatch], Bool, URLResponse), Error> {
        let method = "team/\(key)/event/\(eventKey)/matches"
        return callArray(method: method)
    }

    @discardableResult
    public func fetchTeamAwards(key: String, eventKey: String) -> AnyPublisher<([TBAAward], Bool, URLResponse), Error> {
        let method = "team/\(key)/event/\(eventKey)/awards"
        return callArray(method: method)
    }

    @discardableResult
    public func fetchTeamStatus(key: String, eventKey: String) -> AnyPublisher<(TBAEventStatus?, Bool, URLResponse), Error> {
        let method = "team/\(key)/event/\(eventKey)/status"
        return callDictionary(method: method).tryMap { (dictionary, unmodified, response) -> (TBAEventStatus?, Bool, URLResponse) in
            var dictionary = dictionary
            dictionary["team_key"] = key
            dictionary["event_key"] = eventKey

            if let status = TBAEventStatus(json: dictionary) {
                return (status, unmodified, response)
            } else {
                throw APIError.error("Unexpected response from server.")
            }
        }.eraseToAnyPublisher()
    }

    public func fetchTeamAwards(key: String, year: Int? = nil) -> AnyPublisher<([TBAAward], Bool, URLResponse), Error> {
        var method = "team/\(key)/awards"
        if let year = year {
            method = "\(method)/\(year)"
        }
        return callArray(method: method)
    }
    
    public func fetchTeamMatches(key: String, year: Int) -> AnyPublisher<([TBAMatch], Bool, URLResponse), Error> {
        let method = "team/\(key)/matches/\(year)"
        return callArray(method: method)
    }
    
    public func fetchTeamMedia(key: String, year: Int) -> AnyPublisher<([TBAMedia], Bool, URLResponse), Error> {
        let method = "team/\(key)/media/\(year)"
        return callArray(method: method)
    }
    
    public func fetchTeamSocialMedia(key: String) -> AnyPublisher<([TBAMedia], Bool, URLResponse), Error> {
        let method = "team/\(key)/social_media"
        return callArray(method: method)
    }

}
