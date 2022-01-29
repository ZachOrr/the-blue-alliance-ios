//
//  TBADistrictPointsTiebreaker.swift
//  TBADistrictPointsTiebreaker
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBADistrictPointsTiebreaker {
    // public var teamKey: String
    public var highestQualScores: [Int]
    public var qualWins: Int
}

extension TBADistrictPointsTiebreaker: Decodable {
    enum CodingKeys: String, CodingKey {
        case highestQualScores = "highest_qual_scores"
        case qualWins = "qual_wins"
    }
}
