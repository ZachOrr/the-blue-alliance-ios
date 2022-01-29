//
//  TBADistrictRanking.swift
//  TBADistrictRanking
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBADistrictRanking {
    public var teamKey: String
    public var rank: Int
    public var rookieBonus: Int?
    public var pointTotal: Int
    public var eventPoints: [TBADistrictEventPoints]
    /*
    var eventPoints: [TBADistrictEventPoints] = []
    if let eventPointsJSON = json["event_points"] as? [[String: Any]] {
        for var result in eventPointsJSON {
            // Add team key to JSON
            result["team_key"] = teamKey

            if let eventPoint = TBADistrictEventPoints(json: result) {
                eventPoints.append(eventPoint)
            }
        }
    }
    self.eventPoints = eventPoints
    */
}

extension TBADistrictRanking: Decodable {
    enum CodingKeys: String, CodingKey {
        case teamKey = "team_key"
        case rank
        case rookieBonus = "rookie_bonus"
        case pointTotal = "point_total"
        case eventPoints = "event_points"
    }
}
