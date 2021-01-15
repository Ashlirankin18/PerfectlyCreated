//
//  Extension+Alerts.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/18/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Shows an alert controler without an action.
    /// - Parameters:
    ///   - title: The title of the alert controller
    ///   - message: The message of the controller.
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { alert in }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /// Shows an alert with an non destructive action.
    /// - Parameters:
    ///   - title: The title of the alert controller.
    ///   - message: The message of the controller.
    ///   - style: The style of the alert controller.
    ///   - handler: The action handler.
    func showAlert(title: String?, message: String?, style: UIAlertController.Style, handler: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            handler()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    /// Presents a destructive alert controller
    /// - Parameters:
    ///   - title: The title of the alert controller.
    ///   - message: The message of the alert controller.
    ///   - destructiveTitle: The title of the destructive action.
    ///   - destructiveCompletion: The action
    ///   - nonDestructiveTitle: The non destructive title.
    func persentDestructiveAlertController(title: String?, message: String?, destructiveTitle: String, destructiveCompletion: @escaping () -> Void, nonDestructiveTitle: String ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let destructiveAction = UIAlertAction(title: destructiveTitle, style: .destructive) { _ in
            destructiveCompletion()
        }
        let nonDestructiveAction = UIAlertAction(title: nonDestructiveTitle, style: .cancel, handler: nil)
        alertController.addAction(nonDestructiveAction)
        alertController.addAction(destructiveAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
