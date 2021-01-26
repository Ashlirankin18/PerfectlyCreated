//
//  CategorySectionHeaderCollectionReusableView.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 11/1/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit

/// `UICollectionReusableView` subclass which displays the title of a section.
final class CategorySectionHeaderCollectionReusableView: UICollectionReusableView {
    
    struct ViewModel {
        
        var title: String
    }
    
    @IBOutlet private weak var sectionTitleLabel: UILabel!
    
    var viewModel: ViewModel? {
        didSet {
            sectionTitleLabel.text = viewModel?.title
        }
    }
}
