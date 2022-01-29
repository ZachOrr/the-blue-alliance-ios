//
//  TBAEventRankingRanking.swift
//  TBAEventRankingRanking
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAEventRankingRanking {
    public var teamKey: String
    public var rank: Int
    public var dq: Int?
    public var matchesPlayed: Int?
    public var qualAverage: Double?
    public var record: TBAWLT?
    public var extraStats: [Double]?
    public var sortOrders: [Double]?
}

extension TBAEventRankingRanking: Decodable {
    enum CodingKeys: String, CodingKey {
        case teamKey = "team_key"
        case rank
        case dq
        case matchesPlayed = "matches_played"
        case qualAverage = "qual_average"
        case record
        case extraStats = "extra_stats"
        case sortOrders = "sort_orders"
    }
}
