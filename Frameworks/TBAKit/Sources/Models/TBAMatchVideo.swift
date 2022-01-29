//
//  TBAMatchVideo.swift
//  TBAMatchVideo
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAMatchVideo {
    public var key: String
    public var type: String
}

extension TBAMatchVideo: Decodable {
    enum CodingKeys: String, CodingKey {
        case key
        case type
    }
}
