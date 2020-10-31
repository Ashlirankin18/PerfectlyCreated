//
//  SettingsTableViewController.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 3/7/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController {
  @IBOutlet var editProfileView: UIView!
  
  @IBOutlet weak var emailLabel: UILabel!
  private var initialView: UIView?
  private var updateButton: UIBarButtonItem!
  weak var userSession: UserSession!
  private var firebaseUser: UserModel!

  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    userSession = AppDelegate.userSession
    userSession.userSessionSignOutDelegate = self
    
    if let myView = initialView {
      view = myView
    }
    getUserFromFirebase()
  }
  
  @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
    dismiss(animated: true)
  }
  
  @IBAction func signOutPressed(_ sender: UIButton) {
    userSession.signOut()
  }
  
  @IBAction func EditProfilePressed(_ sender: UIButton) {
    self.initialView = view
    updateButton = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(updateButtonPressed))
    self.navigationItem.rightBarButtonItem = updateButton
    setUserData()
    self.view = editProfileView
    
  }
  
  @objc private func updateButtonPressed(){
    guard let currentView = editProfileView as? EditProfileView else {return}
DataBaseManager.firebaseDB.collection(FirebaseCollectionKeys.users).document(firebaseUser.documentId).updateData(["userName":currentView.userName.text ?? "no username found",
                                                                                               "hairType":currentView.userHairType.text ?? "no hair type found", "bio":currentView.userBio.text                                                            ]) { (error) in
                                                                                                if let error = error{
                                                                                                  print(error.localizedDescription)
                                                                                                }
                                                                                                print("fields sucessfully updated")
                                                                                              
    }
    view = initialView
    updateButton.isEnabled = false
    
  }
  
  
  
  private func getUserFromFirebase() {
    guard let user = userSession.getCurrentUser()else{return}
    DataBaseManager.firebaseDB.collection(FirebaseCollectionKeys.users).document(user.uid).addSnapshotListener({ [weak self] (snapshot, error) in
      if let error = error{
        print(error.localizedDescription)
      }else if let snapshot = snapshot {
        if let userData = try? snapshot.data(as: UserModel.self){
            self?.firebaseUser = userData
          self?.emailLabel.text = self?.firebaseUser.email
        }
      }
    })
    
    }
  

  private func setUserData(){
    guard let newView = editProfileView as? EditProfileView,
      let firebaseUser = firebaseUser else {return}
    newView.userName.delegate = self
    newView.userHairType.delegate = self
    newView.userName.text = firebaseUser.userName
    if let userImage = firebaseUser.profileImageLink{
      newView.UserImage.kf.setImage(with: URL(string: userImage),placeholder:#imageLiteral(resourceName: "placeholder.png"))
    }
    
  }
}

extension SettingsTableViewController: UserSessionSignOutDelegate{
  func didReceiveSignOutError(_ userSession: UserSession, error: Error) {
    showAlert(title: "Error", message: "There was an error signing out: \(error.localizedDescription)")
    
  }
  
  func didSignOutUser(_userSession: UserSession) {
    showAlert(title: "Sign Out Sucessful", message: "You were sucessfully signed out")
    let window = (UIApplication.shared.delegate as! AppDelegate).window
    let signUpViewController = UIStoryboard(name: "SignUpViewController", bundle: .main).instantiateViewController(identifier: "SignUpViewController") { coder in
        return SignupViewController(coder: coder, accountFlow: .signUp)
    }
    window?.rootViewController = signUpViewController
  }
}
extension SettingsTableViewController: UITextFieldDelegate{
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

