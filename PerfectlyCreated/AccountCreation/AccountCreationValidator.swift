//
//  AccountCreationValidator.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 11/25/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import Foundation
import Combine

final class AccountCreationValidator {
    
    @Published var emailText = ""
    
    @Published var passwordText = ""
    
    @Published var usernameText = ""
    
    var readyToSubmit: AnyPublisher<Bool, Never> {
        return $emailText.combineLatest($passwordText)
            .map { !$0.isEmpty && !$1.isEmpty }
            .eraseToAnyPublisher()
    }
    
    func formatUserName() {
        guard !emailText.isEmpty, let index = emailText.index(of: "@") else {
            return
        }
        
        let rightIndex = emailText.index(before: index)
        let formattedString = emailText.prefix(through: rightIndex)
        print(formattedString)
    }
}
