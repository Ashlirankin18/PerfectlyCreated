//
//  EditProductViewController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 12/18/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit

/// `UIViewController` subclass which allows a user to edit their profile.
final class EditProductViewController: UIViewController {
    
    private enum Section: Hashable {
        case info
        case notes
    }
    
    private enum SectionData: Hashable {
        case info(ProductModel)
        case notes(String)
    }
    
    @IBOutlet private weak var editProductCollectionView: UICollectionView!
   
    private lazy var editProductDataSource: UICollectionViewDiffableDataSource<Section, SectionData> = UICollectionViewDiffableDataSource(collectionView: self.editProductCollectionView) { collectionView, indexPath, model  in
        return self.configureCell(model: model)
    }
    
    private let productModel: ProductModel
    
    init?(coder: NSCoder, productModel: ProductModel) {
        self.productModel = productModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        reloadDataSource()
    }
    
    private func configureLayout() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.backgroundColor = .systemPurple
        editProductCollectionView.collectionViewLayout =
            UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    private func configureCell(model: SectionData) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    private func reloadDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SectionData>()
        snapshot.appendSections([.info, .notes])
        snapshot.appendItems([.info(productModel)], toSection: .info)
        snapshot.appendItems([.notes(productModel.productDescription)], toSection: .notes)
        editProductDataSource.apply(snapshot)
    }
}
