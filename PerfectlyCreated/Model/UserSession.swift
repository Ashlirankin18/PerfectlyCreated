//
//  CurrentUser.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/5/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import Foundation
import FirebaseAuth

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
    
    private var documentId: String {
        return DataBaseManager.firebaseDB.collection(FirebaseCollectionKeys.users).document().documentID
    }
    
    func createUser(email: String, password: String, username: String) throws {
        let userId = documentId
        let user = UserModel(userName: username, email: email, profileImageLink: nil, documentId: userId)
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResults, error) in
            
            if let error = error {
                print(error)
                self.userSessionAccountdelegate?.didReceiveError(self, error: error)
            }
            
            if let authDataResults = authDataResults {
                self.userSessionAccountdelegate?.didCreateAccount(self, user: authDataResults.user)
                
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
            userSessionSignOutDelegate?.didSignOutUser(_userSession: self)
        }catch{
            userSessionSignOutDelegate?.didReceiveSignOutError(self, error: error)
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
