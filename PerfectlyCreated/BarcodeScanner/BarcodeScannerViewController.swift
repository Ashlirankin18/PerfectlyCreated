//
//  BarcodeScannerViewController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 10/31/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit
import Combine
import FirebaseAuth
import SwiftUI

/// `UIViewController` subclass which displays the barcode scanner.
final class BarcodeScannerViewController: UIViewController {
    
    @IBOutlet private weak var barcodeView: UIView!
    
    private lazy var videoSession = VideoSessionController()
    
    private var cancelButton = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .done, target: nil, action: nil)
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var productManager = ProductManager()
    
    @ObservedObject var viewModel: ViewModel = ViewModel()
    
    /// Subscriber to this publisher to recieve chages related to the barcode.
    var barcodeStringPublisher: AnyPublisher<String, Error> {
        return barcodeStringSubject.eraseToAnyPublisher()
    }
    
    private var barcodeStringSubject = PassthroughSubject<String, Error>()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCancelButton()
        configureBarcodeScannerPublisher()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoSession.configureCaptureDevice(with: barcodeView)
    }

    // MARK: - BarcodeScannerViewController
    
    private func configureCancelButton() {
        cancelButton.tintColor = .white
        navigationItem.leftBarButtonItem = cancelButton
        navigationController?.configuresShadowlessTransparentNavigationBar(backgroundColor: .black)
        
        cancelButton.tapPublisher.sink { [weak self] _ in
            self?.dismiss(animated: true  )
        }
        .store(in: &cancellables)
    }
    
    private func configureBarcodeScannerPublisher() {
        videoSession.bacodeStringPublisher
            .removeDuplicates()
            .sink { [weak self] result in
                switch result {
                case let .failure(error):
                    self?.dismiss(animated: true)
                    self?.barcodeStringSubject.send(completion: .failure(error))
                case .finished: break
                }
            } receiveValue: { [weak self] barcodeString in
                guard let self = self else {
                    return
                }
                self.queryForProduct(with: barcodeString)
            }.store(in: &cancellables)
    }
    
    private func queryForProduct(with barcodeString: String) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        productManager.retrieveProduct(upc: barcodeString) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case let .failure(error):
                switch error {
                case .productNotFound:
                    self.viewModel.barcodeString = barcodeString
                    let productView = AddProductView(viewModel: self.viewModel) {
                        self.dismiss(animated: true)
                    } saveButtonTapped: { [weak self] in
                        guard let self = self else {
                            return
                        }
                       
                        let newProduct: ProductModel = ProductModel(productName: self.viewModel.productName, documentId: self.productManager.documentId, productDescription: "This product has no description", userId: currentUser.uid, productImageURL: self.viewModel.snapshotURL()?.absoluteString ?? "", category: "Uncategorized", isCompleted: false, notes: nil, upc: self.viewModel.barcodeString, stores: [])
                        self.productManager.addProduct(product: newProduct) { result in
                            switch result {
                            case let .failure(error):
                                    self.showAlert(title: "Error!", message: error.localizedDescription)
                            case .success:
                                    self.dismiss(animated: true)
                            }
                        }
                    }
                    let hostingController = UIHostingController(rootView: productView)
                    self.present(hostingController, animated: true)
                default:
                    self.dismiss(animated: true)
                    self.showAlert(title: "Error!", message: error.localizedDescription)
                }
              
            case let .success(product):
                let newProduct = ProductModel(productName: product.itemAttributes.title, documentId: self.productManager.documentId, productDescription: product.itemAttributes.itemAttributesDescription, userId: currentUser.uid, productImageURL: product.itemAttributes.image, category: product.itemAttributes.category, isCompleted: false, notes: nil, upc: product.upc, stores: product.stores)
                
                let productController =
                    UIStoryboard(name: ProductDetailViewController.nibName, bundle: .main).instantiateViewController(identifier: ProductDetailViewController.nibName) { coder in
                        return ProductDetailViewController(coder: coder, productType: .general, productModel: newProduct)
                    }
                self.show(productController, sender: self)
                return
            }
        }
    }
}
