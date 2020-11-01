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
    
    private var searchController: SearchProductViewController = {
        let controller = UIStoryboard(name: "SearchProductViewController", bundle: .main).instantiateViewController(identifier: "SearchProductViewController") { coder in
            return SearchProductViewController(coder: coder)
        }
        return controller
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       configureButtonTapHandler()
    }
    
    private func configureButtonTapHandler() {
        addBarButtonItem.tapPublisher.sink { [weak self] _ in
            self?.showAlertController()
        }
        .store(in: &cancellables)
    }
    
    private func showAlertController() {
        let alertController = UIAlertController(title: "Add Product", message: nil, preferredStyle: .actionSheet)
        
        let uploadProductAction = UIAlertAction(title: "Upload barcode", style: .default) { _ in
            
        }
        
        let scanBarCodeAction = UIAlertAction(title: "Scan barcode", style: .default) { _ in
            
        }
        
       let searchProduct = UIAlertAction(title: "Search", style: .default) {[weak self] _ in
        
        guard let self = self else {
            return
        }
        let controller  = UINavigationController(rootViewController: self.searchController)
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
       }
        
        alertController.addAction(uploadProductAction)
        alertController.addAction(scanBarCodeAction)
        alertController.addAction(searchProduct)
        
        present(alertController, animated: true)
    }
}
