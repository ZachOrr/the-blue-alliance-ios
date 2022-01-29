//
//  TBAAllianceBackup.swift
//  TBAAllianceBackup
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAAllianceBackup: Decodable {
    public var teamIn: String
    public var teamOut: String
}

extension TBAAllianceBackup {
    enum CodingKeys: String, CodingKey {
        case teamIn = "in"
        case teamOut = "out"
    }
}
