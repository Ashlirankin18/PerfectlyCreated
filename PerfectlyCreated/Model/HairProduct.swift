//
//  HairProduct.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 1/14/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct HairProduct: Codable, Hashable, Equatable {
   
    let itemAttributes: ItemAttributes
    
    let stores: [Store]
    
    enum CodingKeys: String, CodingKey {
        case itemAttributes = "item_attributes"
        case stores = "Stores"
    }
}
