//
//  Status.swift
//
//
//  Created by Zachary Orr on 6/11/21.
//

import Foundation

public struct Status: Decodable {
    public var android: AppInfo
    public var ios: AppInfo
    public var currentSeason: Int
    public var downEvents: [String]
    public var datafeedDown: Bool
    public var maxSeason: Int

    enum CodingKeys: String, CodingKey {
        case android
        case ios
        case currentSeason = "current_season"
        case downEvents = "down_events"
        case datafeedDown = "is_datafeed_down"
        case maxSeason = "max_season"
    }
}

public struct AppInfo: Decodable {
    public var latestAppVersion: Int
    public var minAppVersion: Int

    enum CodingKeys: String, CodingKey {
        case latestAppVersion = "latest_app_version"
        case minAppVersion = "min_app_version"
    }
}
