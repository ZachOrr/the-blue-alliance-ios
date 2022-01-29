//
//  TBAStatus.swift
//  TBAStatus
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAStatus {
    public var android: TBAAppInfo
    public var ios: TBAAppInfo
    public var currentSeason: Int
    public var downEvents: [String]
    public var datafeedDown: Bool
    public var maxSeason: Int
}

extension TBAStatus: Decodable {
    enum CodingKeys: String, CodingKey {
        case android
        case ios
        case currentSeason = "current_season"
        case downEvents = "down_events"
        case datafeedDown = "is_datafeed_down"
        case maxSeason = "max_season"
    }
}
