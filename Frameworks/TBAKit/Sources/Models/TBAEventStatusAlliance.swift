//
//  TBAEventStatusAlliance.swift
//  TBAEventStatusAlliance
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAEventStatusAlliance {
    public var number: Int
    public var pick: Int
    public var name: String?
    public var backup: TBAAllianceBackup?
}

extension TBAEventStatusAlliance: Decodable {
    enum CodingKeys: String, CodingKey {
        case number
        case pick
        case name
        case backup
    }
}
