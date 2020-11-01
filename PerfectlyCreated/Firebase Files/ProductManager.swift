//
//  ProductManager.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 11/1/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ProductManager {
   
    let firebaseDB: Firestore = {
      let db = Firestore.firestore()
      let settings = db.settings
      db.settings = settings
      return db
    }()
    
    var documentId: String {
        return DataBaseManager.firebaseDB.collection(FirebaseCollectionKeys.users).document().documentID
    }
    
    func addProduct(product: ProductModel, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try firebaseDB.collection(FirebaseCollectionKeys.products).document(product.documentId).setData(from: product)
            completion(.success(()))
            return
        } catch {
            completion(.failure(error))
            return
        }
    }
}
