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
    @IBOutlet private weak var productCollectionView: UICollectionView!
    
    private var searchController: SearchProductViewController = {
        let controller = UIStoryboard(name: "SearchProductViewController", bundle: .main).instantiateViewController(identifier: "SearchProductViewController") { coder in
            return SearchProductViewController(coder: coder)
        }
        return controller
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    private var productsDictionary: [ProductModel] = [] {
        didSet {
            reloadDataSource(models: productsDictionary)
        }
    }
    
    private lazy var productManager = ProductManager()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<String, ProductModel> = UICollectionViewDiffableDataSource(collectionView: self.productCollectionView) { (_, indexPath, model) -> UICollectionViewCell? in
        return self.configureCell(model: model, indexPath: indexPath)
    }
    
    private let productCellCollectionLayoutSection: NSCollectionLayoutSection = {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75), heightDimension: .fractionalWidth(0.6))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)
        return section
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productCollectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        productCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: productCellCollectionLayoutSection)
        productCollectionView.dataSource = dataSource
        configureButtonTapHandler()
        retrieveProducts()
    }
    
    private func retrieveProducts() {
        productManager.retrieveProducts { (result) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(models):
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
      
        guard let cell = productCollectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as? ProductCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.productImageView.kf.setImage(with: URL(string: model.productImageURL))
        cell.productNameLabel.text = model.productName
        return cell
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
    
    private func reloadDataSource(models: [ProductModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, ProductModel>()
        
        let sections = Set(models.map { $0.category })

        snapshot.appendSections(Array(sections))
        
        sections.forEach { section in
            let model = models.filter { $0.category == section }
             snapshot.appendItems(model, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
