//
//  BarcodeScannerViewController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 10/31/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit
import Combine

final class BarcodeScannerViewController: UIViewController {
    
    @IBOutlet private weak var barcodeView: UIView!
    
    private lazy var videoSession = VideoSessionController(backgroundView: barcodeView)
    
    private var cancelButton = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .done, target: nil, action: nil)
    
    private var allHairProducts = [AllHairProducts]()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCancelButton()
        allHairProducts = ProductDataManager.getProducts().sorted{$0.results.name < $1.results.name}
        
        videoSession.bacodeStringPublisher
            .first()
            .sink { [weak self] result in
                switch result {
                    case let .failure(error):
                        self?.showAlert(title: "Error!", message: error.localizedDescription)
                    case .finished: break
                }
            } receiveValue: { [weak self] barcodeString in
                
                guard let self = self else {
                    return
                }
                let product = self.allHairProducts.first { $0.results.name == barcodeString }
                
                if let productUnwrapped = product {
                    
                    let productController =
                        UIStoryboard(name: ProductDetailViewController.defaultNibName, bundle: .main).instantiateViewController(identifier: ProductDetailViewController.defaultNibName) { coder in
                            return ProductDetailViewController(coder: coder, productType: .general(productUnwrapped))
                        }
                    self.present(productController, animated: true)
                } else {
                    self.showAlert(title: "Product Not Found", message: "Could not find product in our database.", style: .alert) {
                        self.dismiss(animated: true)
                    }
                }
            }.store(in: &cancellables)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoSession.configureCaptureDevice()
    }
    
    // MARK: - BarcodeScannerViewController
    
    private func configureCancelButton() {
        cancelButton.tintColor = .white
        navigationItem.leftBarButtonItem = cancelButton
        navigationController?.configuresShadowlessTransparentNavigationBar(backgroundColor: .black)
        
        cancelButton.tapPublisher.sink { _ in
            self.dismiss(animated: true  )
        }
        .store(in: &cancellables)
    }
}
