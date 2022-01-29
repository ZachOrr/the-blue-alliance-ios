//
//  TBAEventInsights.swift
//  TBAEventInsights
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAEventInsights {
    public var qual: [String: Any]?
    public var playoff: [String: Any]?
}

extension TBAEventInsights: Decodable {

    enum CodingKeys: String, CodingKey {
        case qual
        case playoff
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        qual = try values.decodeIfPresent([String: Any].self, forKey: .qual)
        playoff = try values.decodeIfPresent([String: Any].self, forKey: .playoff)
    }

}
