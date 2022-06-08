//
//  ProductDisplayViewViewModel.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 6/7/22.
//  Copyright © 2022 Ashli Rankin. All rights reserved.
//

import Foundation

@MainActor class ProductDisplayViewViewModel: ObservableObject {
    
   @Published private(set) var products: [ProductModel] = []
    
    private let productManager = ProductManager()
    
    func retrieveFavoritedProducts() {
        productManager.retrieveProducts { result in
            switch result {
            case .success(let success):
                self.products = success
            case .failure(let failure):
                print(failure)
            }
        }
    }
}
