//
//  TBAMedia.swift
//  TBAMedia
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAMedia {
    public var type: String
    public var foreignKey: String
    public var details: [String: Any]?
    public var preferred: Bool
    public var directURL: String?
    public var viewURL: String?
}

extension TBAMedia: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case foreignKey = "foreign_key"
        case details
        case preferred
        case directURL = "direct_url"
        case viewURL = "view_url"
    }
}
