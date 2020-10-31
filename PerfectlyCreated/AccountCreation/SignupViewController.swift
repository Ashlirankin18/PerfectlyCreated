//
//  SignupViewController.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/4/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Combine
import CombineCocoa

final class SignupViewController: UIViewController {
    
    enum AccountFlow {
        case signIn
        case signUp
    }
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var signInButton: UIButton!
    
    @Published var emailText = ""
    
    @Published var passwordText = ""
    
    @Published var usernameText = ""
    
    private lazy var userSession: UserSession = UserSession()
    
    private let accountFlow: AccountFlow
    
    private var cancellables = Set<AnyCancellable>()
    
    init?(coder: NSCoder, accountFlow: AccountFlow) {
        self.accountFlow = accountFlow
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheDelegates()
        configureTapHandlers()
        configureTextfieldHandlers()
    }
    
    private func configureViews() {
        switch accountFlow {
        case .signIn:
            emailTextField.isHidden = true
        case .signUp:
            emailTextField.isHidden = false
        }
    }
    
    private func setTheDelegates() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
    }
    
    private func configureTapHandlers() {
        
        signUpButton.tapPublisher.sink { [weak self] _ in
            guard let self = self  else {
                return
            }
            
            guard !self.emailText.isEmpty, !self.passwordText.isEmpty else {
                return
            }
            
            do {
               try self.userSession.createUser(email: self.emailText, password: self.passwordText, username: self.usernameText)
            } catch {
                print(error.localizedDescription)
            }
        }
        .store(in: &cancellables)
    }
    
    private func configureTextfieldHandlers() {
        emailTextField.textPublisher.sink { emailText in
            guard let text = emailText else {
                return
            }
            self.emailText = text
        }
        .store(in: &cancellables)
        
        passwordTextField.textPublisher.sink { emailText in
            guard let text = emailText else {
                return
            }
            self.passwordText = text
        }
        .store(in: &cancellables)
        
        usernameTextField.textPublisher.sink { emailText in
            guard let text = emailText else {
                return
            }
            self.usernameText = text
        }
        .store(in: &cancellables)
    }
}

extension SignupViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SignupViewController: UserSessionAccountCreationDelegate {
    
    func didReceiveError(_ userSession: UserSession, error: Error) {
        showAlert(title: "Error!", message: "There was an error logging in: \(error.localizedDescription)")
    }
    
    func didCreateAccount(_ userSession: UserSession, user: User) {
        showAlert(title: "Alert Created", message: "Your account was successfully created")
    }
}
