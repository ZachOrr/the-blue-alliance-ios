//
//  TBAMatchAlliance.swift
//  TBAMatchAlliance
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAMatchAlliance {
    public var score: Int
    public var teams: [String]
    public var surrogateTeams: [String]?
    public var dqTeams: [String]?
}

extension TBAMatchAlliance: Decodable {
    enum CodingKeys: String, CodingKey {
        case score
        case teams = "team_keys"
        case surrogateTeams = "surrogate_team_keys"
        case dqTeams = "dq_team_keys"
    }
}
