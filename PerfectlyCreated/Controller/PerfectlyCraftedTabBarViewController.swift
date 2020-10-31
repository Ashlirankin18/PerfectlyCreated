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
        self.view.backgroundColor = #colorLiteral(red: 0.6722700215, green: 1, blue: 0.6019102933, alpha: 1)
        getAllHairProducts()
        setUpTabbarItems()
    }
    
    
    private func setUpTabbarItems() {
        
        let profileViewController = ProfileViewController.init(view: ProfileView())
        let profileNavigationController = UINavigationController(rootViewController: profileViewController)
        
        let searchViewController = SearchProductViewController()
        let searchNavigationController = UINavigationController(rootViewController: searchViewController)
        let myProductViewController = UIStoryboard.init(name: "ProfileOptions", bundle: nil).instantiateViewController(withIdentifier: "HairProductsTableViewController")
        
        profileViewController.tabBarItem.image = #imageLiteral(resourceName: "icons8-user-26")
        profileViewController.title = "Profile"
        searchViewController.tabBarItem.image = #imageLiteral(resourceName: "icons8-search-25")
        searchViewController.title = "Search"
        myProductViewController.tabBarItem.image = #imageLiteral(resourceName: "icons8-spray-filled-25.png")
        myProductViewController.title = "My Products"
        
        self.viewControllers = [myProductViewController, searchNavigationController, profileNavigationController]
        
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
