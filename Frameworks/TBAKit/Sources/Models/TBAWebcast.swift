//
//  TBAWebcast.swift
//  TBAWebcast
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAWebcast {

    public var type: String
    public var channel: String
    public var file: String?
    public var date: Date?
    
    /*
    public init(type: String, channel: String, file: String? = nil, date: Date? = nil) {
        self.type = type
        self.channel = channel
        self.file = file
        self.date = date
    }

    init?(json: [String: Any]) {
        // Required: type, channel
        guard let type = json["type"] as? String else {
            return nil
        }
        self.type = type
        
        guard let channel = json["channel"] as? String else {
            return nil
        }
        self.channel = channel

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let dateString = json["date"] as? String, let date = dateFormatter.date(from: dateString) {
            self.date = date
        }

        self.file = json["file"] as? String
    }
    */
}

extension TBAWebcast: Decodable {}
