//
//  CompletedCollectionViewCell.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 11/2/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit
import Combine

class CompletedCollectionViewCell: UICollectionViewCell {
    
    struct ViewModel {
        
        enum Configuration {
            case display
            case editing
        }
        
        let isCompleted: Bool
        let title: String
        
        let configuration: Configuration
        
        fileprivate var completeImage: UIImage! {
            if isCompleted {
                return UIImage(systemName: "checkmark.circle.fill")
            } else {
                return UIImage(systemName: "checkmark.circle")
            }
        }
        
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var checkmarkButton: UIButton!
    private var cancellables = Set<AnyCancellable>()
    
    var viewModel: ViewModel? {
        didSet {
            
            guard let viewModel = viewModel else {
                return
            }
            titleLabel.text = viewModel.title
            checkmarkButton.setImage(viewModel.completeImage, for: .normal)
            checkmarkButton.isUserInteractionEnabled = viewModel.configuration == .editing
            
            if viewModel.configuration == .editing {
                borderWidth = 1.0
                borderColor = .systemIndigo
                cornerRadius = 10
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkmarkButton.tapPublisher.sink { _ in
            self.checkmarkButton.isSelected.toggle()
            
            if self.checkmarkButton.isSelected {
                self.checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
            } else {
                self.checkmarkButton.setImage(UIImage(systemName: "checkmark.circle"), for: .selected)
            }
        }
        .store(in: &cancellables)
    }
}
