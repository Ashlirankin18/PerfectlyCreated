//
//  StoreCollectionViewCell.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 1/16/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import UIKit

/// <#Description#>
final class StoreCollectionViewCell: UICollectionViewCell {
    
    /// <#Description#>
    struct ViewModel {
        
        /// The image url of the product
        let imageURL: URL
        
        /// The product name.
        let productName: String
        
        /// The store name.
        let storeName: String
        
        /// The price of the product.
        let price: String
    }
    
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var productNameLabel: UILabel!
    @IBOutlet private weak var storeNameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var containerStackView: UIStackView!
    
    var viewModel: ViewModel? {
        didSet {
            productImageView.kf.setImage(with: viewModel?.imageURL)
            productNameLabel.text = viewModel?.productName
            storeNameLabel.text = viewModel?.storeName
            priceLabel.text = viewModel?.price
        }
    }
}
