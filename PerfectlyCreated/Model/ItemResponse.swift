//
//  ItemResponse.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 1/14/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import Foundation

/// Represents the response.
struct ItemResponse: Codable, Equatable, Hashable {
    
    /// The status code of the response
    let code: Int
    
    /// The status
    let status: String
    
    /// The message
    let message: String
}
