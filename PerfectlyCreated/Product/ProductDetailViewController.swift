//
//  ProductDetailViewController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 10/31/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit
import Kingfisher
import Combine
import FirebaseAuth

final class ProductDetailViewController: UIViewController {
   
    @IBOutlet private weak var productImageImageView: UIImageView!
    @IBOutlet private weak var productNameLabel: UILabel!
    @IBOutlet private weak var productDescriptionTextView: UITextView!
    @IBOutlet private weak var addProductBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let product: AllHairProducts
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var productManager = ProductManager()
    
    init?(coder: NSCoder, product: AllHairProducts) {
        self.product = product
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureBarButtonTapHandler()
    }
    
    private func configureUI() {
        productNameLabel.text = product.results.name
        productImageImageView.kf.setImage(with: product.results.images.first)
        productDescriptionTextView.text = product.results.description
    }
    
    private func configureBarButtonTapHandler() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let model = product.results
        let product = ProductModel(productName: model.name, documentId: productManager.documentId, productDescription: model.description, userId: currentUser.uid, productImageURL: model.images.first?.absoluteString ?? "", category: model.category, isCompleted: false)
        addProductBarButtonItem.tapPublisher.sink {  _ in
            
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self.productManager.addProduct(product: product) { [weak self] result in
                guard let self = self else {
                    return
                }
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                switch result {
                case let .failure(error):
                    print(error)
                case .success:
                    self.dismiss(animated: true)
                }
            }
        }
        .store(in: &cancellables)
    }
}
