//
//  AboutProductCollectionViewCell.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 11/1/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit

/// `UICollectionViewCell` which displays information about a product.
final class AboutProductCollectionViewCell: UICollectionViewCell {
    
    /// Contains the information needed to configure `AboutProductCollectionViewCell`.
    struct ViewModel {
        
        /// The name of the product.
        let productName: String
        
        /// The product description.
        let productDescription: String
        
        /// The image url of the product.
        let imageURL: URL?
        
        /// The product category.
        let category: String
    }
    
    @IBOutlet private weak var productImageImageView: UIImageView!
    @IBOutlet private weak var productNameLabel: UILabel!
    @IBOutlet private weak var productDescriptionTextView: UITextView!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    
    /// Single point of configuration of the `AboutProductCollectionViewCell`.
    var viewModel: ViewModel? {
        didSet {
            productNameLabel.text = viewModel?.productName
            categoryLabel.text = viewModel?.category
            productImageImageView.kf.setImage(with: viewModel?.imageURL)
            if viewModel?.productDescription.isEmpty ?? true {
                productDescriptionTextView.isHidden = true
            }
            productDescriptionTextView.text = viewModel?.productDescription
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.cornerRadius = 20
        containerView.addShadow(location: .top)
    }
}
