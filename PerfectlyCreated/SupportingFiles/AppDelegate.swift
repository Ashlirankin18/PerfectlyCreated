//
//  AppDelegate.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/4/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit
import Firebase
import Combine
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private lazy var cancellables = Set<AnyCancellable>()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        FirebaseApp.configure()
        
        if UserDefaults.standard.object(forKey: "userId") != nil {
            window?.rootViewController = UIHostingController(rootView: ProductDisplayView())
            self.window?.makeKeyAndVisible()
        } else {
            let signUpViewController = UIStoryboard(name: SignupViewController.nibName, bundle: .main).instantiateViewController(identifier: SignupViewController.nibName) { coder in
                return SignupViewController(coder: coder, accountFlow: .signUp)
            }
            self.window?.rootViewController = signUpViewController
            self.window?.makeKeyAndVisible()
        }
        
        NotificationCenter.default.publisher(for: .signupSuccessfullyCompleted, object: nil).sink { [weak self] _ in
            guard let self = self else {
                return
            }
            self.window?.rootViewController = PerfectlyCraftedTabBarViewController()
            self.window?.makeKeyAndVisible()
        }
        .store(in: &cancellables)
        
        return true
    }
}
