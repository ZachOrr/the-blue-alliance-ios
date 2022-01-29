//
//  TBAMatch.swift
//  TBAMatch
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAMatch {
    public var key: String
    public var compLevel: String
    public var setNumber: Int
    public var matchNumber: Int
    public var alliances: [String: TBAMatchAlliance]?
    public var winningAlliance: String?
    public var eventKey: String
    public var time: Int64?
    public var actualTime: Int64?
    public var predictedTime: Int64?
    public var postResultTime: Int64?
    public var breakdown: [String: Any]?
    public var videos: [TBAMatchVideo]?
}

extension TBAMatch: Decodable {
    enum CodingKeys: String, CodingKey {
        case key
        case compLevel = "comp_level"
        case setNumber = "set_number"
        case matchNumber = "match_number"
        case alliances
        case winningAlliance = "winning_alliance"
        case eventKey = "event_key"
        case time
        case actualTime = "actual_time"
        case predictedTime = "predicted_time"
        case postResultTime = "post_result_time"
        case breakdown = "score_breakdown"
        case videos
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try values.decode(String.self, forKey: .key)
        compLevel = try values.decode(String.self, forKey: .compLevel)
        setNumber = try values.decode(Int.self, forKey: .setNumber)
        matchNumber = try values.decode(Int.self, forKey: .matchNumber)
        alliances = try values.decodeIfPresent([String: TBAMatchAlliance].self, forKey: .alliances)
        winningAlliance = try values.decodeIfPresent(String.self, forKey: .winningAlliance)
        eventKey = try values.decode(String.self, forKey: .eventKey)
        time = try values.decodeIfPresent(Int64.self, forKey: .time)
        actualTime = try values.decodeIfPresent(Int64.self, forKey: .actualTime)
        predictedTime = try values.decodeIfPresent(Int64.self, forKey: .predictedTime)
        postResultTime = try values.decodeIfPresent(Int64.self, forKey: .postResultTime)
        breakdown = try values.decodeIfPresent([String: Any].self, forKey: .breakdown)
        videos = try values.decodeIfPresent([TBAMatchVideo].self, forKey: .videos)
    }
}
