//
//  TBAAppInfo.swift
//  TBAAppInfo
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAAppInfo: Equatable {
    public var latestAppVersion: Int
    public var minAppVersion: Int
}

extension TBAAppInfo: Decodable {
    enum CodingKeys: String, CodingKey {
        case latestAppVersion = "latest_app_version"
        case minAppVersion = "min_app_version"
    }
}
