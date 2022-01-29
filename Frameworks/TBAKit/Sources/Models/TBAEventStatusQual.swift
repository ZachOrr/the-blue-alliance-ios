//
//  TBAEventStatusQual.swift
//  TBAEventStatusQual
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAEventStatusQual {
    public var numTeams: Int?
    public var status: String?
    public var ranking: TBAEventRanking?
    public var sortOrder: [TBAEventRankingSortOrder]?
}

extension TBAEventStatusQual: Decodable {
    enum CodingKeys: String, CodingKey {
        case numTeams = "num_teams"
        case status
        case ranking
        case sortOrderInfo = "sort_order_info"
    }
}
