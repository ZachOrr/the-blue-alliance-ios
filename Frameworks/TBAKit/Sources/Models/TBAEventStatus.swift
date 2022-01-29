//
//  TBAEventStatus.swift
//  TBAEventStatus
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAEventStatus {
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
}

extension TBAEventStatus: Decodable {
    enum CodingKeys: String, CodingKey {
        case qual
        case alliance
        case playoff
        case allianceStatusString = "alliance_status_str"
        case playoffStatusString = "playoff_status_str"
        case overallStatusString = "overall_status_str"
        case nextMatchKey = "next_match_key"
        case lastMatchKey = "last_match_key"
    }
}
