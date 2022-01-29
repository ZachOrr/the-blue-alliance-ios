//
//  TBAMachZebraTeam.swift
//  TBAMachZebraTeam
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAMachZebraTeam {
    public var teamKey: String
    public var xs: [Double?]
    public var ys: [Double?]
}

extension TBAMachZebraTeam: Decodable {
    enum CodingKeys: String, CodingKey {
        case teamKey = "team_key"
        case xs
        case ys
    }
}
