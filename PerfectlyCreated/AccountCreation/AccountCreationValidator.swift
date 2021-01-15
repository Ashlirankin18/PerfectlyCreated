//
//  AccountCreationValidator.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 11/25/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import Foundation
import Combine

/// An object that stores intermediate state of the user account.
final class AccountCreationValidator {
    
    /// A published property for raw text of the email text field.
    @Published var emailText = ""
    
    /// A published property for raw text of the password text field.
    @Published var passwordText = ""
    
    /// A published property for raw text of the username text field.
    @Published var usernameText = ""
    
    /// / A Publisher that represents if the data is ready to be submitted.
    var readyToSubmit: AnyPublisher<Bool, Never> {
        return $emailText.combineLatest($passwordText)
            .map { !$0.isEmpty && !$1.isEmpty }
            .eraseToAnyPublisher()
    }
    
    /// Formats the user's email to create their username.
    func formatUserName() {
        guard !emailText.isEmpty, let index = emailText.firstIndex(of: "@") else {
            return
        }
        
        let rightIndex = emailText.index(before: index)
        let formattedString = emailText.prefix(through: rightIndex)
        print(formattedString)
    }
}
