//
//  TBAStat.swift
//  TBAStat
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAStat {
    
    public var teamKey: String
    public var ccwm: Double
    public var dpr: Double
    public var opr: Double
    
    /*
    public init(teamKey: String, ccwm: Double, dpr: Double, opr: Double) {
        self.teamKey = teamKey
        self.ccwm = ccwm
        self.dpr = dpr
        self.opr = opr
    }

    init?(json: [String: Any]) {
        guard let teamKey = json["team_key"] as? String else {
            return nil
        }
        self.teamKey = teamKey
        
        guard let ccwm = json["ccwm"] as? Double else {
            return nil
        }
        self.ccwm = ccwm

        guard let dpr = json["dpr"] as? Double else {
            return nil
        }
        self.dpr = dpr
        
        guard let opr = json["opr"] as? Double else {
            return nil
        }
        self.opr = opr
    }
    */

}

extension TBAStat: Decodable {}
