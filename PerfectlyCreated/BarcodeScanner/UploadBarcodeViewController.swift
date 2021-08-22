//
//  UploadBarcodeViewController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 1/13/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import UIKit
import Combine
import SwiftUI
import FirebaseAuth
import PhotosUI

/// `UIViewController` subclass which allows the user to upload a bar code.
final class UploadBarcodeViewController: UIViewController {
    
    @IBOutlet private weak var chosenImageImageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var backBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var cropView: UIView!
    @IBOutlet private weak var promptView: UIView!
    
    private lazy var promptController = UIHostingController(rootView: PromptDisplayView(displayVersion: .upload, displayText: "Focus the barcode inside the box to upload.", addButtonTapped: {
        self.present(self.photoController, animated: true)
    }))
    
    @ObservedObject var viewModel: ViewModel = ViewModel()
    
    private lazy var productManager = ProductManager()
    
    private lazy var transitionManager: CardPresentationManager = CardPresentationManager()
    
    private var chosenImage: UIImage
    
    private var cancellables = Set<AnyCancellable>()
    
    private var photoController: PHPickerViewController  = {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let controller = PHPickerViewController(configuration: configuration)
        return controller
    }()
    
    /// Creates a new instance of `UploadBarcodeViewController`.
    /// - Parameters:
    ///   - coder: An abstract class that serves as the basis for objects that enable archiving and distribution of other objects.
    ///   - chosenImage: The chosen image.
    init?(coder: NSCoder, chosenImage: UIImage) {
        self.chosenImage = chosenImage
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoController.modalPresentationStyle = .fullScreen
        photoController.delegate = self
        promptController.view.backgroundColor = .clear
        displayChildViewController(promptController, in: promptView)
        configureBarButtonItems()
        chosenImageImageView.image = chosenImage
        configureScrollView()
        
        configureSaveButton()
        configureBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.configuresShadowlessTransparentNavigationBar(backgroundColor: .black)
    }
    
    // MARK: - UploadBarcodeViewController
    
    private func configureBarButtonItems() {
        backBarButtonItem.tintColor = .white
        saveBarButtonItem.tintColor = .white
    }
    
    private func configureScrollView() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 2
        
        cropView.borderWidth = 5.0
        cropView.cornerRadius = 20
        cropView.borderColor = .white
    }
    
    private func configureSaveButton() {
        saveBarButtonItem.tapPublisher.sink { [weak self] _ in
            guard let self = self else {
                return
            }

        }
        .store(in: &cancellables)
    }
    
    private func configureBackButton() {
        backBarButtonItem.tapPublisher.sink { [weak self] _ in
            self?.dismiss(animated: true)
        }
        .store(in: &cancellables)
    }
    
    private func addNewProduct(barcodeString: String, currentUserId: String) {
        viewModel.barcodeString = barcodeString
        let productView = AddProductView(viewModel: self.viewModel, backButtonTapped: { [weak self] in
            self?.dismiss(animated: true)
        }, saveButtonTapped: { [weak self] in
            guard let self = self else {
                return
            }
            
            let newProduct: ProductModel = ProductModel(productName: self.viewModel.productName, documentId: self.productManager.documentId, productDescription: "This product has no description", userId: currentUserId, productImageURL: self.viewModel.snapshotURL()?.absoluteString ?? "", category: "Uncategorized", isCompleted: false, notes: nil, upc: self.viewModel.barcodeString, stores: [])
            
            self.productManager.addProduct(product: newProduct) { [weak self] result in
                switch result {
                case let .failure(error):
                    self?.showAlert(title: "Error!", message: error.localizedDescription)
                case .success:
                    self?.viewModel.saveImage { url in
                        self?.productManager.updateProduct(documentId: self?.productManager.documentId ?? "", productFields: ["imageProductURL": url.absoluteString], completion: { [weak self] _ in
                            self?.dismiss(animated: true)
                            self?.presentingViewController?.dismiss(animated: true)
                            let hostingController = UIHostingController(rootView: CelebrationView(backButtonTapped: { [weak self] in
                                self?.dismiss(animated: true)
                            }))
                            
                            self?.present(hostingController, animated: true)
                        })
                    }
                    
                }
            }
        })
        let hostingController = UIHostingController(rootView: productView)
        transitionManager.presentationDirection = .bottom
        hostingController.modalPresentationStyle = .custom
        hostingController.transitioningDelegate = transitionManager
        self.present(hostingController, animated: true)
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
                            let alertController = UIAlertController(title: "Product not found", message: "The product was not found would you like to add it?", preferredStyle: .alert)
                            let addAction = UIAlertAction(title: "Add Product", style: .default) { [weak self] _ in
                                self?.addNewProduct(barcodeString: barcodeString, currentUserId: currentUser.uid)
                            }
                            
                            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                            alertController.addAction(addAction)
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true)
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

extension UploadBarcodeViewController: UIScrollViewDelegate {
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return chosenImageImageView
    }
}

extension UploadBarcodeViewController: PHPickerViewControllerDelegate {
    
    // MARK: - PHPickerViewControllerDelegate
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self]  image, _ in
                DispatchQueue.main.async {
                    guard let self = self else {
                        return
                    }
                    if let image = image as? UIImage {
                        self.chosenImageImageView.image = image
                        self.chosenImage = image
                    } else {
                        self.showAlert(title: "Error", message: "Image could not be processed.")
                    }
                }
            }
        }
    }
}
