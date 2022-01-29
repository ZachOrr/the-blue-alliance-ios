//
//  TBAWLT.swift
//  TBAWLT
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAWLT {
    public var wins: Int
    public var losses: Int
    public var ties: Int
    /*
    public init(wins: Int, losses: Int, ties: Int) {
        self.wins = wins
        self.losses = losses
        self.ties = ties
    }

    init?(json: [String: Any]) {
        // Required: wins, losses, ties
        self.wins = json["wins"] as? Int ?? 0
        self.losses = json["losses"] as? Int ?? 0
        self.ties = json["ties"] as? Int ?? 0
    }
    */
}


extension TBAWLT: Decodable {}
