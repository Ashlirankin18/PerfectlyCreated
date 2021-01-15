//
//  PerfectlyCraftedTabBarViewController.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/5/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit
import Combine

/// `UITabBarController` subclass which contais all the controllers dicplayed in the tab.
final class PerfectlyCraftedTabBarViewController: UITabBarController {
    
    private lazy var hairProductApiClient = HairProductApiClient()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UITabBarController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllHairProducts()
        setUpTabBarItems()
    }
    
    // MARK: - PerfectlyCraftedTabBarViewController
    
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
        hairProductApiClient.getHairProducts()?.sink(receiveCompletion: { [weak self] completion in
            switch completion {
                case let .failure(error):
                    self?.showAlert(title: "Error!!", message: error.localizedDescription)
                case .finished: break
            }
        }, receiveValue: { products in
            ProductDataManager.setProducts(products: products)
        })
        .store(in: &cancellables)
    }
}
