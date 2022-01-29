//
//  TBAEventRanking.swift
//  TBAEventRanking
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAEventRanking {
    // TODO: This should be non-null - needs a fix upstream
    public var rankings: [TBAEventRankingRanking]?
    public var extraStatsInfo: [TBAEventRankingSortOrder]?
    public var sortOrderInfo: [TBAEventRankingSortOrder]
}

extension TBAEventRanking: Decodable {
    enum CodingKeys: String, CodingKey {
        case rankings
        case extraStatsInfo = "extra_stats_info"
        case sortOrderInfo = "sort_order_info"
    }
}
