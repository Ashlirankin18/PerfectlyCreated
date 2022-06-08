//
//  ProductModel.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 3/1/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift

/// Represents a product.
struct ProductModel: Codable, Hashable, Identifiable {
    var id: String {
        return documentId
    }
    
    /// The product name.
    let productName: String
    
    /// The document id.
    let documentId: String
    
    /// the product description.
    let productDescription: String
    
    /// The user whose collection it belongs in.
    let userId: String
    
    /// The image url string.
    let productImageURL: String
    
    /// The product category.
    let category: String
    
    /// Wether the product is completed.
    let isCompleted: Bool
    
    /// The notes on the product.
    let notes: String?
    
    let upc: String
    
    let stores: [Store]
}
