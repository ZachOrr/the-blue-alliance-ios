//
//  TBAAward.swift
//  TBAAward
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAAward {
    public var name: String
    public var awardType: Int
    public var eventKey: String
    public var recipients: [TBAAwardRecipient]
    public var year: Int
}

extension TBAAward: Decodable {
    enum CodingKeys: String, CodingKey {
        case name
        case awardType = "award_type"
        case eventKey = "event_key"
        case recipients = "recipient_list"
        case year
    }
}
