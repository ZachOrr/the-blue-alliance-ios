//
//  TBAAPI-main.swift
//
//
//  Created by Zachary Orr on 8/15/24.
//

import Foundation
import TBAAPI

let api = TBAAPI(apiKey: "")
print(try await api.getEvents(year: 2024))
