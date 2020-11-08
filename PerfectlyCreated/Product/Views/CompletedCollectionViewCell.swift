//
//  CompletedCollectionViewCell.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 11/2/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit

class CompletedCollectionViewCell: UICollectionViewCell {
    
    struct ViewModel {
        let isCompleted: Bool
        let title: String
        
        fileprivate var completeImage: UIImage! {
            if isCompleted {
                return UIImage(systemName: "checkmark.circle.fill")
            } else {
                return UIImage(systemName: "checkmark.circle")
            }
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    
    var viewModel: ViewModel? {
        didSet {
            
            guard let viewModel = viewModel else {
                return
            }
            titleLabel.text = viewModel.title
            checkmarkImageView.image = viewModel.completeImage
        }
    }
}
