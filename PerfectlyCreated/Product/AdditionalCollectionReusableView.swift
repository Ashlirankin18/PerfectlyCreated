//
//  AdditionalCollectionReusableView.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 11/1/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit
import Combine

final class AdditionalCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet private weak var editButton: UIButton!
    
    private var cancellables = Set<AnyCancellable>()
    
    var editButtonTapHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editButton.tapPublisher.sink {[weak self] _ in
            self?.editButtonTapHandler?()
        }
        .store(in: &cancellables)
    }
}
