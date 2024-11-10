//
//  TBAAPI+Status.swift
//
//
//  Created by Zachary Orr on 8/15/24.
//

import Foundation

extension TBAAPI {
    public func getStatus() async throws -> Status {
        let response = try await client.getStatus()
        return try convertResponse(response: response.ok.body.json)
    }
}
