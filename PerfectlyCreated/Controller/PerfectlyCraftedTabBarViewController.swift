//
//  PerfectlyCraftedTabBarViewController.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/5/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit

final class PerfectlyCraftedTabBarViewController: UITabBarController {
    
    var allHairProducts = [AllHairProducts]()
    
    var theLocalUser:UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllHairProducts()
        setUpTabbarItems()
    }
    
    
    private func setUpTabbarItems() {
        
        let profileViewController = ProfileViewController.init(view: ProfileView())
        let profileNavigationController = UINavigationController(rootViewController: profileViewController)
        
        let searchViewController = SearchProductViewController()
        let searchNavigationController = UINavigationController(rootViewController: searchViewController)
        let myProductViewController = UIStoryboard(name: "ProductViewController", bundle: .main).instantiateViewController(identifier: "ProductViewController") { coder in
            return ProductViewController(coder: coder)
        }
        let myProductNavigationController = UINavigationController(rootViewController: myProductViewController)
        profileViewController.tabBarItem.image = #imageLiteral(resourceName: "icons8-user-26")
        profileViewController.title = "Profile"
        searchViewController.tabBarItem.image = #imageLiteral(resourceName: "icons8-search-25")
        searchViewController.title = "Search"
        myProductViewController.tabBarItem.image = #imageLiteral(resourceName: "icons8-spray-filled-25.png")
        myProductViewController.title = "My Products"
        
        self.viewControllers = [myProductNavigationController, searchNavigationController, profileNavigationController]
        
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
