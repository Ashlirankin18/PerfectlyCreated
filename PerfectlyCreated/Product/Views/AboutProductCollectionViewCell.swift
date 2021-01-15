//
//  AboutProductCollectionViewCell.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 11/1/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit

final class AboutProductCollectionViewCell: UICollectionViewCell {
    
    struct ViewModel {
        let productName: String
        let productDescription: String
        let productURL: URL?
        let category: String
    }
    
    @IBOutlet private weak var productImageImageView: UIImageView!
    @IBOutlet private weak var productNameLabel: UILabel!
    @IBOutlet private weak var productDescriptionTextView: UITextView!
    @IBOutlet private weak var categoryLabel: UILabel!
    
    var viewModel: ViewModel? {
        didSet {
            productNameLabel.text = viewModel?.productName
            categoryLabel.text = viewModel?.category
            productImageImageView.kf.setImage(with: viewModel?.productURL)
            if viewModel?.productDescription.isEmpty ?? true {
                productDescriptionTextView.isHidden = true
            }
            productDescriptionTextView.text = viewModel?.productDescription
            
        }
    }
}

