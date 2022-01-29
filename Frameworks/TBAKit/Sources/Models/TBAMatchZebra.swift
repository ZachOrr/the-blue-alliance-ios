//
//  TBAMatchZebra.swift
//  TBAMatchZebra
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAMatchZebra {
    public var key: String
    public var times: [Double]
    public var alliances: [String: [TBAMachZebraTeam]]
}

extension TBAMatchZebra: Decodable {}
