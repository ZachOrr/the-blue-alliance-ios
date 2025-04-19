//
//  Status.swift
//
//
//  Created by Zachary Orr on 6/11/21.
//

import Foundation

public struct Status: Decodable {
    public var ios: AppInfo
    public var currentSeason: Int
    public var downEvents: [String]
    public var datafeedDown: Bool
    public var maxSeason: Int

    enum CodingKeys: String, CodingKey {
        case ios
        case currentSeason = "current_season"
        case downEvents = "down_events"
        case datafeedDown = "is_datafeed_down"
        case maxSeason = "max_season"
    }

    public init(ios: AppInfo, currentSeason: Int, downEvents: [String], datafeedDown: Bool, maxSeason: Int) {
        self.ios = ios
        self.currentSeason = currentSeason
        self.downEvents = downEvents
        self.datafeedDown = datafeedDown
        self.maxSeason = maxSeason
    }
}

public struct AppInfo: Decodable {
    public var latestAppVersion: Int
    public var minAppVersion: Int

    enum CodingKeys: String, CodingKey {
        case latestAppVersion = "latest_app_version"
        case minAppVersion = "min_app_version"
    }

    public init(latestAppVersion: Int, minAppVersion: Int) {
        self.latestAppVersion = latestAppVersion
        self.minAppVersion = minAppVersion
    }

    public init() {
        self.latestAppVersion = -1
        self.minAppVersion = -1
    }
}
