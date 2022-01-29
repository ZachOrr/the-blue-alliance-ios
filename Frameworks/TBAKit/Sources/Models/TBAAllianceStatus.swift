//
//  TBAAllianceStatus.swift
//  TBAAllianceStatus
//
//  Created by Zachary Orr on 9/15/21.
//

import Foundation

public struct TBAAllianceStatus {
    public var currentRecord: TBAWLT?
    public var level: String?
    public var playoffAverage: Double?
    public var record: TBAWLT?
    public var status: String?
    
    /*
    public init(currentRecord: TBAWLT? = nil, level: String? = nil, playoffAverage: Double? = nil, record: TBAWLT? = nil, status: String? = nil) {
        self.currentRecord = currentRecord
        self.level = level
        self.playoffAverage = playoffAverage
        self.record = record
        self.status = status
    }

    init?(json: [String: Any]) {
        if let currentRecordJSON = json["current_level_record"] as? [String: Any] {
            self.currentRecord = TBAWLT(json: currentRecordJSON)
        }
        
        self.level = json["level"] as? String
        self.playoffAverage = json["playoff_average"] as? Double
        
        if let recordJSON = json["record"] as? [String: Any] {
            self.record = TBAWLT(json: recordJSON)
        }
        
        self.status = json["status"] as? String
    }
    */
}

extension TBAAllianceStatus: Decodable {
    enum CodingKeys: String, CodingKey {
        case currentRecord = "current_level_record"
        case level
        case playoffAverage = "playoff_average"
        case record
        case status
    }
}
