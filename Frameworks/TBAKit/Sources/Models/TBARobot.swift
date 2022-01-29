//
//  TBARobot.swift
//  TBARobot
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBARobot {
    public var key: String
    public var name: String
    public var teamKey: String
    public var year: Int
}


extension TBARobot: Decodable {
    enum CodingKeys: String, CodingKey {
        case key
        case name = "robot_name"
        case teamKey = "team_key"
        case year
    }
}
