//
//  TBAAlliance.swift
//  TBAAlliance
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAAlliance {
    public var name: String?
    public var backup: TBAAllianceBackup?
    public var declines: [String]?
    public var picks: [String]
    public var status: TBAAllianceStatus?
}

extension TBAAlliance: Decodable {}
