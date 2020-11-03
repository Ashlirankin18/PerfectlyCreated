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
    }
    
    @IBOutlet private weak var productImageImageView: UIImageView!
    @IBOutlet private weak var productNameLabel: UILabel!
    @IBOutlet private weak var productDescriptionTextView: UITextView!
    
    
    var viewModel: ViewModel? {
        didSet {
            productNameLabel.text = viewModel?.productName
            productImageImageView.kf.setImage(with: viewModel?.productURL)
            productDescriptionTextView.text = viewModel?.productDescription
        }
    }
}

