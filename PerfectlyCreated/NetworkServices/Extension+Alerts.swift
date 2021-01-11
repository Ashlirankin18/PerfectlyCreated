//
//  Extension+Alerts.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/18/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { alert in }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String?, message: String?, style: UIAlertController.Style, handler: @escaping (UIAlertController) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        handler(alertController)
    }
    
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
