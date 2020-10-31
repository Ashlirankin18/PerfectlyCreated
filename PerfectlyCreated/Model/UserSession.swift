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

protocol UserSessionAccountCreationDelegate:AnyObject {
    func didReceiveError(_ userSession: UserSession, error:Error)
    func didCreateAccount(_ userSession:UserSession,user:User)
}

protocol UserSessionSignOutDelegate:AnyObject{
    func didReceiveSignOutError(_ userSession:UserSession,error:Error)
    func didSignOutUser(_userSession:UserSession)
}

protocol UserSessionSignInExistingUserDelegate:AnyObject {
    func didReceiveSignInError(_ userSession: UserSession,error:Error)
    func didSignInUser(_ userSession: UserSession, user: User)
}

final class UserSession {
    
    weak var userSessionAccountdelegate: UserSessionAccountCreationDelegate?
    weak var userSessionSignOutDelegate: UserSessionSignOutDelegate?
    weak var userSignInDelegate: UserSessionSignInExistingUserDelegate?
    
    var accountCreationPassThroughSubject = PassthroughSubject<Result<Void, Error>, Never>()
    var signOutPassThroughSubject = PassthroughSubject<Result<Void, Error>, Never>()
    
    
    private var documentId: String {
        return DataBaseManager.firebaseDB.collection(FirebaseCollectionKeys.users).document().documentID
    }
    
    func createUser(email: String, password: String, username: String) throws {
        let userId = documentId
        let user = UserModel(userName: username, email: email, profileImageLink: nil, documentId: userId)
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResults, error) in
            
            if let error = error {
                self.accountCreationPassThroughSubject.send(.failure(error))
            } else {
                self.accountCreationPassThroughSubject.send((.success(())))
                do {
                    try DataBaseManager.firebaseDB.collection(FirebaseCollectionKeys.users).document(userId).setData(from: user)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    func signOut() {
        do{
            try Auth.auth().signOut()
            signOutPassThroughSubject.send(.success(()))
        }catch{
            signOutPassThroughSubject.send(.failure(error))
        }
    }
    
    func signInExistingUser(email:String,password:String){
        Auth.auth().signIn(withEmail: email, password: password) { (results, error) in
            if let error = error{
                self.userSignInDelegate?.didReceiveSignInError(self, error: error)
            }
            else if let results = results{
                self.userSignInDelegate?.didSignInUser(self, user: results.user)
            }
        }
    }
}
