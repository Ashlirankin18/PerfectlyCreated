//
//  Store.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 1/14/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import Foundation


// MARK: - Store
struct Store: Codable, Equatable, Hashable {
    let storeName, title: String
    let image: String
    let price, currency: String
    let link: String
    let updated: String
    
    enum CodingKeys: String, CodingKey {
        case storeName = "store_name"
        case title, image, price, currency, link, updated
    }
}
