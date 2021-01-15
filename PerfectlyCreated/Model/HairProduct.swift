//
//  HairProduct.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 1/14/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import Foundation

/// Represents a hair product.
struct HairProduct: Codable, Hashable, Equatable {
    
    /// The item attributes.
    let itemAttributes: ItemAttributes
    
    /// The stores where the product can be found.
    let stores: [Store]
    
    enum CodingKeys: String, CodingKey {
        case itemAttributes = "item_attributes"
        case stores = "Stores"
    }
}
