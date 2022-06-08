//
//  SearchProductView.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 6/7/22.
//  Copyright © 2022 Ashli Rankin. All rights reserved.
//

import SwiftUI

struct SearchProductView: View {
    
    @StateObject private var searchProductViewViewModel = SearchProductViewViewModel()
    
    var body: some View {
        NavigationStack {
            List(searchProductViewViewModel.products, id: \.self) { product in
                SearchRowView(name: product.results.name, category:  product.results.category, imageURL: product.results.images.first)
            }
            .navigationTitle("Products")
            .task {
                searchProductViewViewModel.retrieveSearchProducts()
            }
        }
    }
}

struct SearchProductView_Previews: PreviewProvider {
    static var previews: some View {
        SearchProductView()
    }
}
