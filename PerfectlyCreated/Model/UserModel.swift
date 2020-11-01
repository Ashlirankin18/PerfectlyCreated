//
//  UserModel.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/5/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift

struct UserModel: Codable {
    let userName:String
    let email:String
    let profileImageLink: String?
    let documentId: String
    let productIds: [String]
}
