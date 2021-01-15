//
//  Store.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 1/14/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import Foundation

/// Represents a store object.
struct Store: Codable, Equatable, Hashable {
    
    /// The name of the store which has the product.
    let storeName: String
    
    /// The title of the product
    let title: String
    
    /// The image url string associate with the product.
    let image: String
    
    /// The price of the product.
    let price: String
    
    /// The currency
    let currency: String
    
    /// The product link
    let link: String
    
    /// When the product was last updated.
    let updated: String
    
    enum CodingKeys: String, CodingKey {
        case storeName = "store_name"
        case title, image, price, currency, link, updated
    }
}
