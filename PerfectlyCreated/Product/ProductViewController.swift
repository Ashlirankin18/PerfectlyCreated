//
//  ProductViewController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 10/31/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit
import CombineCocoa
import Combine

final class ProductViewController: UIViewController {

    @IBOutlet private weak var addBarButtonItem: UIBarButtonItem!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       configureButtonTapHandler()
    }
    
    private func configureButtonTapHandler() {
        addBarButtonItem.tapPublisher.sink { [weak self] _ in
            
        }
        .store(in: &cancellables)
    }
}
