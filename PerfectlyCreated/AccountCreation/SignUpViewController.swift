//
//  SignUpViewController.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/4/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit
import FirebaseAuth

final class SignUpViewController: UIViewController {
    
    enum AccountFlow {
        case signIn
        case signUp
    }
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var signInButton: UIButton!
    
    private var userSession: UserSession!
    
    private let accountFlow: AccountFlow
    
    init?(coder: NSCoder, accountFlow: AccountFlow) {
        self.accountFlow = accountFlow
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheDelegates()
    }
    
    private func configureViews() {
        switch accountFlow {
        case .signIn:
            emailTextField.isHidden = true
        case .signUp:
            emailTextField.isHidden = false
        }
    }
    
    private func setTheDelegates(){
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
        userSession = AppDelegate.userSession
    }
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SignUpViewController:UserSessionAccountCreationDelegate {
    
    func didReceiveError(_ userSession: UserSession, error: Error) {
        showAlert(title: "Error!", message: "There was an error logging in: \(error.localizedDescription)")
    }
    
    func didCreateAccount(_ userSession: UserSession, user: User) {
        showAlert(title: "Alert Created", message: "Your account was successfully created")
    }
}
