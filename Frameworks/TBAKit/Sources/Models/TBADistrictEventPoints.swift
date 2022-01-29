//
//  TBADistrictEventPoints.swift
//  TBADistrictEventPoints
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

/*
public struct APIEventDistrictPoints: Decodable {
    public var points: [String: APIEventDistrictPointsPoints]
    public var tiebreakers: [String: APIEventDistrictPointsTiebreaker]
}
*/

public struct TBADistrictEventPoints: Equatable {
    public var teamKey: String
    public var eventKey: String
    public var districtCMP: Bool?
    public var alliancePoints: Int
    public var awardPoints: Int
    public var qualPoints: Int
    public var elimPoints: Int
    public var total: Int
}

extension TBADistrictEventPoints: Decodable {
    enum CodingKeys: String, CodingKey {
        // TODO: teamKey??
        case eventKey = "event_key"
        case districtCMP = "district_cmp"
        case alliancePoints = "alliance_points"
        case awardPoints = "award_points"
        case qualPoints = "qual_points"
        case elimPoints = "elim_points"
        case total
    }
}

// APIEventDistrictPointsTiebreaker
