//
//  TBAKit+Match.swift
//  
//
//  Created by Zachary Orr on 6/13/21.
//

import Foundation

extension TBAKit {

    public func match(key: String) async throws -> TBAMatch {
        let endpoint = "match/\(key)"
        return try await fetch(endpoint)
    }

    public func matchZebra(key: String) async throws -> TBAMatch {
        let endpoint = "match/\(key)/zebra_motionworks"
        return try await fetch(endpoint)
    }

}
