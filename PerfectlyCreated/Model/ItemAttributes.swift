//
//  ItemAttributes.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 1/14/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import Foundation

struct ItemAttributes: Codable, Equatable, Hashable {
   
    let title, upc, category: String
    let image: String
    let itemAttributesDescription: String
    
    enum CodingKeys: String, CodingKey {
        case title, upc
        case category = "parent_category"
        case image
        case itemAttributesDescription = "description"
    }
}

