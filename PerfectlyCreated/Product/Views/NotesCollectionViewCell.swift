//
//  NotesCollectionViewCell.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 11/8/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit

final class NotesCollectionViewCell: UICollectionViewCell {
    
    /// Contains the information needed to configure `NotesCollectionViewCell`.
    struct ViewModel {
        
        /// The title of the cell.
        let title: String
        
        /// The notes the user has added to the product.
        let notes: String
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var notesTextView: UITextView!
    
    /// Single point of configuration of `NotesCollectionViewCell`.
    var viewModel: ViewModel? {
        didSet {
            titleLabel.text = viewModel?.title
            notesTextView.text = viewModel?.notes
        }
    }
}
