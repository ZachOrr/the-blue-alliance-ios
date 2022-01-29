//
//  TBADistrict.swift
//  TBADistrict
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBADistrict {
    public var abbreviation: String
    public var name: String
    public var key: String
    public var year: Int
}

extension TBADistrict: Decodable {
    enum CodingKeys: String, CodingKey {
        case abbreviation
        case name = "display_name"
        case key
        case year
    }
}
