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

final class ProductViewController: UICollectionViewController {
    
    @IBOutlet private weak var addBarButtonItem: UIBarButtonItem!
    
    private var searchController: SearchProductViewController = {
        let controller = UIStoryboard(name: "SearchProductViewController", bundle: .main).instantiateViewController(identifier: "SearchProductViewController") { coder in
            return SearchProductViewController(coder: coder)
        }
        return controller
    }()
    
    private lazy var barcodeScannerViewController = BarcodeScannerViewController(nibName: BarcodeScannerViewController.defaultNibName, bundle: .main)
    
    private var cancellables = Set<AnyCancellable>()
    
    private var productsDictionary: [ProductModel] = [] {
        didSet {
            reloadDataSource(models: productsDictionary)
        }
    }
    
    private var sectionTitles = [String]()
    
    private lazy var productManager = ProductManager()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<String, ProductModel> = UICollectionViewDiffableDataSource(collectionView: self.collectionView) { (_, indexPath, model) -> UICollectionViewCell? in
        return self.configureCell(model: model, indexPath: indexPath)
    }
    
    private let productCellCollectionLayoutSection: NSCollectionLayoutSection = {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "CategorySectionHeaderCollectionReusableView", alignment: .top)
     
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.7))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        group.interItemSpacing = .fixed(24)
        
        let section = NSCollectionLayoutSection(group: group)
    
        section.boundarySupplementaryItems = [sectionHeader]
        
        section.interGroupSpacing = 24
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 0)
        return section
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureCollectionView()
        configureButtonTapHandler()
        retrieveProducts()
        configureHeaders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.configuresShadowlessOpaqueNavigationBar()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureCollectionView() {
        collectionView.register(UINib(nibName: ProductCollectionViewCell.defaultNibName, bundle: .main), forCellWithReuseIdentifier: ProductCollectionViewCell.defaultNibName)
        collectionView.register(UINib(nibName: CategorySectionHeaderCollectionReusableView.defaultNibName, bundle: .main), forSupplementaryViewOfKind: "view", withReuseIdentifier: CategorySectionHeaderCollectionReusableView.defaultNibName)
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: productCellCollectionLayoutSection)
        collectionView.dataSource = dataSource
    }
    
    private func retrieveProducts() {
        productManager.retrieveProducts { (result) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(models):
                let sections = Set(models.map { $0.category })
                self.sectionTitles = Array(sections)
                self.productsDictionary = models
            }
        }
    }
    
    private func configureButtonTapHandler() {
        addBarButtonItem.tapPublisher.sink { [weak self] _ in
            self?.showAlertController()
        }
        .store(in: &cancellables)
    }
    
    private func configureCell(model: ProductModel, indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewCell.defaultNibName, for: indexPath) as? ProductCollectionViewCell else {
            return UICollectionViewCell()
        }
        let borderColor: UIColor = model.isCompleted ? UIColor.systemIndigo : UIColor.systemIndigo.withAlphaComponent(0.5)
        cell.borderColor = borderColor
        cell.productImageView.kf.setImage(with: URL(string: model.productImageURL))
        cell.productNameLabel.text = model.productName
        return cell
    }
    
    private func showAlertController() {
        let alertController = UIAlertController(title: "Add Product", message: nil, preferredStyle: .actionSheet)
        
        let uploadProductAction = UIAlertAction(title: "Upload barcode", style: .default) { _ in
           
        }
        
        let scanBarCodeAction = UIAlertAction(title: "Scan barcode", style: .default) { [weak self] _ in
            guard let self = self else {
                return
            }
            let navigationController = UINavigationController(rootViewController: self.barcodeScannerViewController)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true)
            
        }
        
        let searchProduct = UIAlertAction(title: "Search", style: .default) { [weak self] _ in
            
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
    
    private func reloadDataSource(models: [ProductModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, ProductModel>()
        
        snapshot.appendSections(sectionTitles)
        
        sectionTitles.forEach { section in
            let model = models.filter { $0.category == section }
            snapshot.appendItems(model, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureHeaders() {
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: "view", withReuseIdentifier: "CategorySectionHeaderCollectionReusableView", for: indexPath) as? CategorySectionHeaderCollectionReusableView else {
                return nil
            }
            
            header.sectionTitleLabel.text = self.sectionTitles[indexPath.section]
            
            return header
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedProduct = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        let productController =
            UIStoryboard(name: ProductDetailViewController.defaultNibName, bundle: .main).instantiateViewController(identifier: ProductDetailViewController.defaultNibName) { coder in
                return ProductDetailViewController(coder: coder, productType: .personal(selectedProduct))
            }
        navigationController?.pushViewController(productController, animated: true)
    }
}
