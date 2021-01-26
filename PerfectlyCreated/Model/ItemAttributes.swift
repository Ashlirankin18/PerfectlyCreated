//
//  ItemAttributes.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 1/14/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import Foundation

/// Represents the product attributes.
struct ItemAttributes: Codable, Equatable, Hashable {
    
    /// The title of the product.
    let title: String
    
    /// The barcode number.
    let upc: String
    
    /// The category of the product.
    let category: String
    
    /// The product image url
    let image: String
    
    /// the product description.
    let itemAttributesDescription: String
    
    enum CodingKeys: String, CodingKey {
        case title, upc
        case category = "parent_category"
        case image
        case itemAttributesDescription = "description"
    }
}
