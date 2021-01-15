//
//  PerfectlyCraftedTabBarViewController.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/5/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit

/// `UITabBarController` subclass which contais all the controllers dicplayed in the tab.
final class PerfectlyCraftedTabBarViewController: UITabBarController {
    
    //MARK : - UITabBarController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllHairProducts()
        setUpTabBarItems()
    }
    
    //MARK : - PerfectlyCraftedTabBarViewController
    private func setUpTabBarItems() {
        let myProductViewController = UIStoryboard(name: ProductViewController.defaultNibName, bundle: .main).instantiateViewController(identifier: ProductViewController.defaultNibName) { coder in
            return ProductViewController(coder: coder)
        }
        let myProductNavigationController = UINavigationController(rootViewController: myProductViewController)
        myProductViewController.tabBarItem.image = #imageLiteral(resourceName: "icons8-spray-filled-25.png")
        myProductViewController.title = "My Products"
        
        self.viewControllers = [myProductNavigationController]
    }
    
    private func getAllHairProducts() {
        HairProductApiClient.getHairProducts { (error, allHairProducts) in
            if let error = error {
                print(error.errorMessage())
            }
            if let allHairProducts = allHairProducts{
                ProductDataManager.setProducts(products: allHairProducts)
            }
        }
    }
}
