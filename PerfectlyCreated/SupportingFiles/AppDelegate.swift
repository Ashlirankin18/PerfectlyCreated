//
//  AppDelegate.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/4/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit
import Firebase
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        FirebaseApp.configure()
        
        let rootController: UIViewController
        
        if let _ = Auth.auth().currentUser {
            rootController = PerfectlyCraftedTabBarViewController()
        }else{
            let signUpViewController = UIStoryboard(name: "SignupViewController", bundle: .main).instantiateViewController(identifier: "SignupViewController") { coder in
                return SignupViewController(coder: coder, accountFlow: .signUp)
            }
            rootController = signUpViewController
        }
        
        window?.rootViewController = rootController
        window?.makeKeyAndVisible()
        return true
    }
}

