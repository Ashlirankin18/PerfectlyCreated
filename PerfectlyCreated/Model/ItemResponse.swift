//
//  ItemResponse.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 1/14/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import Foundation

// MARK: - ItemResponse
struct ItemResponse: Codable, Equatable, Hashable {
    let code: Int
    let status, message: String
}
