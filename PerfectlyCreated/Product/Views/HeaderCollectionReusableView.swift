//
//  HeaderCollectionReusableView.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 2/3/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import UIKit

final class HeaderCollectionReusableView: UICollectionReusableView {

    struct ViewModel {
        let title: String
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    var viewModel: ViewModel? {
        didSet {
            titleLabel.text = viewModel?.title
        }
    }
}
