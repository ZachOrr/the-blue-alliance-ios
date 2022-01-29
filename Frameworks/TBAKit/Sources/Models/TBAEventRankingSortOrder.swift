//
//  TBAEventRankingSortOrder.swift
//  TBAEventRankingSortOrder
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAEventRankingSortOrder {
    
    public var name: String
    public var precision: Int
    
    /*
    public init(name: String, precision: Int) {
        self.name = name
        self.precision = precision
    }

    init?(json: [String: Any]) {
        // Required: name, precision
        guard let name = json["name"] as? String else {
            return nil
        }
        self.name = name
        
        guard let precision = json["precision"] as? Int else {
            return nil
        }
        self.precision = precision
    }
    */
}

extension TBAEventRankingSortOrder: Decodable {}
