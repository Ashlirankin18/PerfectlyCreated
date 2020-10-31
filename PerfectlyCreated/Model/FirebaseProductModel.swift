//
//  FirebaseProductModel.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 3/1/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift

struct ProductModel: Codable {
  
  let productName: String
  let documentId: String
  let productDescription: String
  var userId:String
  var productImage: String
  let category: String
  var isCompleted: Bool
  
}

