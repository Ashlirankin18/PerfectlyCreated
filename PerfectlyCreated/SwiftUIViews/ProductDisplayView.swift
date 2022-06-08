//
//  ProductDisplayView.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 6/7/22.
//  Copyright © 2022 Ashli Rankin. All rights reserved.
//

import SwiftUI

struct ProductDisplayView: View {
    
    private enum AddProductOptions: Identifiable {
    
        case search
        case scan
        
        var id: AddProductOptions {
            return self
        }
    }
    
    @StateObject private var productDisplayViewModel = ProductDisplayViewViewModel()
    
    @State private var shouldPresentActionSheet = false
    @State private var addProductOptions: AddProductOptions?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [.init(), .init()]) {
                    ForEach(productDisplayViewModel.products, id: \.self) { product in
                        ProductRow(name: product.productName, category: product.category, imageURL: URL(string: product.productImageURL))
                    }
                }
                .padding(16)
                Spacer()
            }
            .navigationTitle("Products")
            .task {
                productDisplayViewModel.retrieveFavoritedProducts()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        shouldPresentActionSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .foregroundColor(Color(uiColor: UIColor(named: "darkBlue")!))
                }
            }
            .confirmationDialog("Add Product", isPresented: $shouldPresentActionSheet) {
                Button {
                    addProductOptions = .search
                } label: {
                    Text("Search")
                }

                Button {
                    addProductOptions = .scan
                } label: {
                    Text("Scan Barcode")
                }
            }
            .sheet(item: $addProductOptions) { option in
                switch option {
                case .scan:
                    Text("Scan View")
                case .search:
                    SearchProductView()
                }
            }
        }
    }
}

struct ProductDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDisplayView()
    }
}
