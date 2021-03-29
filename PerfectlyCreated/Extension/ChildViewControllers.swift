//
//  ChildViewControllers.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 3/29/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Adds a child viewController to the current controller.
    /// - Parameter viewController: The child view controller that will be displayed.
    func displayChildViewController(_ viewController: UIViewController, in view: UIView) {
        
        addChild(viewController)
        
        view.addSubview(viewController.view)
        
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParent: self)
    }
    
    /// Removes a child viewController to the current controller.
    /// - Parameter viewController: The child view controller that will be displayed.
    func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}
