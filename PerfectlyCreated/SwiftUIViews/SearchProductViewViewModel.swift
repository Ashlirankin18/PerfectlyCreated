//
//  SearchProductViewViewModel.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 6/7/22.
//  Copyright © 2022 Ashli Rankin. All rights reserved.
//

import Foundation
import Combine

@MainActor final class SearchProductViewViewModel: ObservableObject {
    
    private lazy var hairProductApiClient = HairProductApiClient()
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var products: [AllHairProducts] = []
    
    func retrieveSearchProducts() {
        hairProductApiClient.getHairProducts()?.sink(result: { result in
            switch result {
            case .success(let success):
                self.products = success
            case .failure(let failure):
                print(failure)
            }
        })
        .store(in: &cancellables)
    }
}
