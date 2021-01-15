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
import FirebaseAuth

/// Manages the networking logic related to the product.
final class ProductManager {
    
    private let firebaseDB: Firestore = {
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        return db
    }()
    
    /// The document id
    var documentId: String {
        return firebaseDB.collection(FirebaseCollectionKeys.users).document().documentID
    }
    
    private static var products = [AllHairProducts]()
    
    /// Sets the products.
    /// - Parameter products: The products to set.
    static func setProducts(products: [AllHairProducts]) {
        self.products = products
    }
    
    /// Reteieves the products
    /// - Returns: the returned products.
    static func getProducts() -> [AllHairProducts] {
        return self.products
    }
    
    /// Adds a product to the database
    /// - Parameters:
    ///   - product: The product to be added.
    ///   - completion: Called on completion of the network call.
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
    
    /// Adds a hair product retrieve from the barcode lookup api to the database.
    /// - Parameters:
    ///   - documentId: The new document id.
    ///   - product: The product to be added.
    ///   - completion: Called on completion of the network logic.
    func addProduct(documentId: String?, product: HairProduct, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let documentId = documentId else {
            return
        }
        
        do {
            try firebaseDB.collection(FirebaseCollectionKeys.allProducts).document(documentId).setData(from: product)
            completion(.success(()))
            return
        } catch {
            completion(.failure(error))
            return
        }
    }
    
    /// Retrieves all the products from the database.
    /// - Parameter completion: Called on completion of the network call.
    func retrieveProducts(completion: @escaping (Result<[ProductModel], Error>) -> Void) {
        
        guard let currentUser =  Auth.auth().currentUser else {
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
    
    /// Retrieves a specific product from the database.
    /// - Parameters:
    ///   - documenId: The document id of the product.
    ///   - completion: Called on completion of the newwork call.
    func retireveProduct(with documenId: String, completion: @escaping (Result<ProductModel, Error>) -> Void) {
        firebaseDB.collection(FirebaseCollectionKeys.products).document(documenId).addSnapshotListener({ (snapshot, error) in
           
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                }
                
                if let snapshot = snapshot {
                    do {
                        guard let model = try snapshot.data(as: ProductModel.self) else {
                            return
                        }
                        completion(.success(model))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        })
    }
    
    /// Deletes a product from the database.
    /// - Parameters:
    ///   - product: The product to be deleted.
    ///   - completionHandler: Called on completion of the network call.
    func deleteProduct(_ product: ProductModel, completionHandler: @escaping (Result<Void, Error>) -> Void ) {
        firebaseDB.collection(FirebaseCollectionKeys.products).document(product.documentId).delete { error in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                completionHandler(.success(()))
            }
        }
    }
    
    /// Updates a product.
    /// - Parameters:
    ///   - documentId: The product document id.
    ///   - productFields: The fields to be updated.
    ///   - completion: Called on completion of the network call.
    func updateProduct(documentId: String, productFields: [String: Any], completion: @escaping ((Result<Void, Error>) -> Void)) {
        firebaseDB.collection(FirebaseCollectionKeys.products).document(documentId).updateData(productFields) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
