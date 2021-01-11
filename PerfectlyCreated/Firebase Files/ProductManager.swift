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
    
    private lazy var userManager = UserManager()
    
    var documentId: String {
        return firebaseDB.collection(FirebaseCollectionKeys.users).document().documentID
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
    
    func retrieveProducts(completion: @escaping (Result<[ProductModel], Error>) -> Void) {
        
        guard let currentUser = userManager.currentUser else {
            return
        }
        
        firebaseDB.collection(FirebaseCollectionKeys.products).whereField("userId", isEqualTo: currentUser.uid).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            }
            if let snapshot = snapshot {
                do {
                    let models = try snapshot.documents.compactMap { snapshotQuery -> ProductModel? in
                        return try snapshotQuery.data(as: ProductModel.self)
                    }
                    completion(.success(models))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func deleteProduct(_ product: ProductModel, completionHandler: @escaping (Result<Void, Error>) -> Void ) {
        firebaseDB.collection(FirebaseCollectionKeys.products).document(product.documentId).delete { error in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                completionHandler(.success(()))
            }
        }
    }
}
