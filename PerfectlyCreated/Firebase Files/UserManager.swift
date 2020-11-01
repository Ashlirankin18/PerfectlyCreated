//
//  UserManager.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 11/1/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

final class UserManager {
    
    let firebaseDB: Firestore = {
      let db = Firestore.firestore()
      let settings = db.settings
      db.settings = settings
      return db
    }()
    
    var currentUser: User? {
        return Auth.auth().currentUser
    }
}
