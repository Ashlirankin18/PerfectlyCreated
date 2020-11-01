//
//  ProductDetailViewController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 10/31/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit
import Kingfisher

final class ProductDetailViewController: UIViewController {
   
    @IBOutlet private weak var productImageImageView: UIImageView!
    @IBOutlet private weak var productNameLabel: UILabel!
    @IBOutlet private weak var productDescriptionTextView: UITextView!
    @IBOutlet private weak var addProductBarButtonItem: UIBarButtonItem!
    
    private let product: AllHairProducts
    
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
    }
    
    private func configureUI() {
        productNameLabel.text = product.results.name
        productImageImageView.kf.setImage(with: product.results.images.first)
        productDescriptionTextView.text = product.results.description
    }
}
