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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureCell()
    }
    
    private func configureCell() {
        layer.cornerRadius = frame.height / 2
        layer.masksToBounds = false
        contentView.layer.cornerRadius = 25
        contentView.layer.masksToBounds = true
        layer.shadowColor = UIColor.appPurple.withAlphaComponent(0.3).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1.0
        
        self.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}
