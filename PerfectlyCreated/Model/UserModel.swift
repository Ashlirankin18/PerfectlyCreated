//
//  UserModel.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 5/3/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import Foundation

struct UserModel: Codable {
    
    let userName: String
    
    let email: String
    
    let profileImageLink: URL?
    
    let documentId: String
    
    let productIds: [String]
}
