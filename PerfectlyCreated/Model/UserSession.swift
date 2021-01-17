//
//  CurrentUser.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/5/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import Foundation
import FirebaseAuth
import Combine
import CombineExt
import FirebaseFirestore

/// Handles all the logic related to user database object.
final class UserSession {
    
    private var accountCreationPassThroughSubject = PassthroughSubject<Void, Error>()
    
    private let firebaseDB: Firestore = {
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        return db
    }()
    
    private var documentId: String {
        return firebaseDB.collection(FirebaseCollectionKeys.users).document().documentID
    }
    
    /// Creates a new user.
    /// - Parameters:
    ///   - email: The email of the user
    ///   - password: The password
    ///   - username: The username
    func createUser(email: String, password: String, username: String) -> AnyPublisher<Void, Error> {
        let userId = documentId
        let user = UserModel(userName: username, email: email, profileImageLink: nil, documentId: userId, productIds: [])
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (auth, error) in
            
            if let error = error {
                self?.accountCreationPassThroughSubject.send(completion: .failure(error))
            } else {
                self?.accountCreationPassThroughSubject.send(())
                do {
                    UserDefaults.standard.setValue(auth?.user.uid, forKey: "userId")
                    try self?.firebaseDB.collection(FirebaseCollectionKeys.users).document(userId).setData(from: user)
                } catch {
                    self?.accountCreationPassThroughSubject.send(completion: .failure(error))
                }
            }
        }
        return accountCreationPassThroughSubject.eraseToAnyPublisher()
    }
    
    /// Gets the current user.
    /// - Returns: The user if there is one.
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    /// Signs out user.
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Signs in the user to their account.
    /// - Parameters:
    ///   - email: The user's email.
    ///   - password: Their pass word.
    /// - Returns: Publisher which publishes void and error.
    func signInExistingUser(email: String, password: String) -> AnyPublisher<Void, Error> {
        AnyPublisher.create { subscriber -> Cancellable in
            Auth.auth().signIn(withEmail: email, password: password) { (auth, error) in
                if let error = error {
                    subscriber.send(completion: .failure(error))
                } else if auth != nil {
                    UserDefaults.standard.setValue(auth?.user.uid, forKey: "userId")
                    subscriber.send(())
                }
            }
            return AnyCancellable { }
        }
        .eraseToAnyPublisher()
    }
}
