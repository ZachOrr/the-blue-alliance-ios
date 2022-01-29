//
//  TBAAwardRecipient.swift
//  TBAAwardRecipient
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAAwardRecipient: Equatable {
    
    // The TBA team key for the team that was given the award. May be null
    public var teamKey: String?
    // The name of the individual given the award. May be null
    public var awardee: String?
    
    /*
    public init(teamKey: String) {
        self.init(teamKey: teamKey, awardee: nil)
    }

    public init(awardee: String) {
        self.init(teamKey: nil, awardee: awardee)
    }

    public init(teamKey: String?, awardee: String?) {
        self.teamKey = teamKey
        self.awardee = awardee
    }

    init?(json: [String: Any]) {
        self.teamKey = json["team_key"] as? String
        self.awardee = json["awardee"] as? String
    }
    */
}

extension TBAAwardRecipient: Decodable {
    enum CodingKeys: String, CodingKey {
        case teamKey = "team_key"
        case awardee
    }
}
