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
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var signInButton: UIButton!
    
    private lazy var userSession: UserSession = UserSession()
    private var accountCreationValidator = AccountCreationValidator()
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
        
        accountCreationValidator.readyToSubmit
            .assign(to: \.isEnabled, on: signUpButton, and: \.isEnabled, on: signInButton)
            .store(in: &cancellables)
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
        passwordTextField.delegate = self
        emailTextField.delegate = self
    }
    
    private func configureTapHandlers() {
        
        signUpButton.tapPublisher.sink { [weak self] _ in
            guard let self = self  else {
                return
            }
            self.accountCreationValidator.formatUserName()
            
            do {
                try self.userSession.createUser(email: self.accountCreationValidator.emailText, password: self.accountCreationValidator.passwordText, username: self.accountCreationValidator.usernameText)
                
                self.userSession.accountCreationPassThroughSubject.sink { [weak self] result in
                    
                    guard let self = self  else {
                        return
                    }
                    
                    switch result {
                    case let .failure(error):
                        self.showAlert(title: "Error!", message: "There was an error signing up : \(error.localizedDescription)")
                    case .success:
                        let controller = PerfectlyCraftedTabBarViewController()
                        controller.modalPresentationStyle = .fullScreen
                        self.show(controller, sender: self)
                    }
                }
                .store(in: &self.cancellables)
            } catch {
                assertionFailure("An error occurred: \(error.localizedDescription)")
            }
        }
        .store(in: &cancellables)
        
        signInButton.tapPublisher.sink { [weak self] _ in
            guard let self = self else {
                return
            }
            self.userSession.signInExistingUser(email: self.accountCreationValidator.emailText, password: self.accountCreationValidator.passwordText).sink { error in
                switch error {
                case let .failure(error):
                    self.showAlert(title: "Error!", message: "There was an error logging in: \(error.localizedDescription)")
                case .finished: break
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else {
                    return
                }
                let controller = PerfectlyCraftedTabBarViewController()
                controller.modalPresentationStyle = .fullScreen
                self.show(controller, sender: self)
            }
            .store(in: &self.cancellables)
        }
        .store(in: &cancellables)
    }
    
    private func configureTextfieldHandlers() {
        emailTextField.textPublisher.sink { [weak self] emailText in
            guard let text = emailText else {
                return
            }
            self?.accountCreationValidator.emailText = text
        }
        .store(in: &cancellables)
        
        passwordTextField.textPublisher.sink { passwordText in
            guard let text = passwordText else {
                return
            }
            self.accountCreationValidator.passwordText = text
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
