//
//  ProductViewController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 10/31/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit
import Combine
import PhotosUI

/// `UICollectionViewController` subclass which displays the user's products.
final class ProductViewController: UICollectionViewController {
    
    @IBOutlet private weak var addBarButtonItem: UIBarButtonItem!
    
    private var searchController: SearchProductViewController = {
        let controller = UIStoryboard(name: SearchProductViewController.defaultNibName, bundle: .main).instantiateViewController(identifier: SearchProductViewController.defaultNibName) { coder in
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
    
    private var sectionTitles = [String]()
    
    private var photoController: PHPickerViewController  = {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let controller = PHPickerViewController(configuration: configuration)
        return controller
    }()
    
    private lazy var barcodeScannerViewController = BarcodeScannerViewController(nibName: BarcodeScannerViewController.defaultNibName, bundle: .main)
    
    private lazy var productManager = ProductManager()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<String, ProductModel> = UICollectionViewDiffableDataSource(collectionView: self.collectionView) { (_, indexPath, model) -> UICollectionViewCell? in
        return self.configureCell(model: model, indexPath: indexPath)
    }
    
    private lazy var hairProductApiClient = HairProductApiClient()
    
    private let productCellCollectionLayoutSection: NSCollectionLayoutSection = {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "CategorySectionHeaderCollectionReusableView", alignment: .top)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.48), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.7))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        group.interItemSpacing = .flexible(0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.boundarySupplementaryItems = [sectionHeader]
        
        section.interGroupSpacing = 0
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10)
        return section
    }()
    
    // MARK: - UICollectionViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoController.modalPresentationStyle = .fullScreen
        photoController.delegate = self
        configureCollectionView()
        configureButtonTapHandler()
        retrieveProducts()
        configureHeaders()
        configureBarcodeScanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.configuresShadowlessTransparentNavigationBar(backgroundColor: .clear)
    }
    
    // MARK: - ProductViewController
    
    private func configureCollectionView() {
        collectionView.register(UINib(nibName: ProductCollectionViewCell.defaultNibName, bundle: .main), forCellWithReuseIdentifier: ProductCollectionViewCell.defaultNibName)
        collectionView.register(UINib(nibName: CategorySectionHeaderCollectionReusableView.defaultNibName, bundle: .main), forSupplementaryViewOfKind: "view", withReuseIdentifier: CategorySectionHeaderCollectionReusableView.defaultNibName)
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: productCellCollectionLayoutSection)
        collectionView.dataSource = dataSource
    }
    
    private func retrieveProducts() {
        productManager.retrieveProducts { [weak self] (result) in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(models):
                let sections = Set(models.map { $0.category })
                self?.sectionTitles = Array(sections)
                self?.productsDictionary = models
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
        cell.viewModel = .init(imageURL: URL(string: model.productImageURL), productName: model.productName)
        return cell
    }
    
    private func showAlertController() {
        let alertController = UIAlertController(title: "Add Product", message: nil, preferredStyle: .actionSheet)
        
        let uploadProductAction = UIAlertAction(title: "Upload barcode", style: .default) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.present(self.photoController, animated: true)
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
            let controller = UINavigationController(rootViewController: self.searchController)
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
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, _, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: "view", withReuseIdentifier: "CategorySectionHeaderCollectionReusableView", for: indexPath) as? CategorySectionHeaderCollectionReusableView else {
                return nil
            }
            header.viewModel = .init(title: self.sectionTitles[indexPath.section])
            
            if self.sectionTitles[indexPath.section].isEmpty {
                header.viewModel?.title = "Uncategorized"
            }
            return header
        }
    }
    
    private func queryForProduct(with barcodeString: String) {
        productManager.retrieveProduct(upc: barcodeString) { [weak self] result in
            switch result {
            case let .failure(error):
                self?.showAlert(title: "Error!", message: error.localizedDescription)
            case let .success(product):
                let productController =
                    UIStoryboard(name: ProductDetailViewController.defaultNibName, bundle: .main).instantiateViewController(identifier: ProductDetailViewController.defaultNibName) { coder in
                        return ProductDetailViewController(coder: coder, productType: .newApi(product))
                    }
                self?.show(productController, sender: self)
            }
        }
    }
    
    private func configureBarcodeScanner() {
        barcodeScannerViewController.barcodeStringPublisher
            .removeDuplicates()
            .sink { [weak self] completion in
            switch completion {
            case let .failure(error):
                self?.showAlert(title: "Error!", message: error.localizedDescription)
            case .finished: break
            }
        } receiveValue: { [weak self] barcodeString in
            self?.queryForProduct(with: barcodeString)
        }
        .store(in: &cancellables)
    }
    
    // MARK: - UICollectionViewDelegate
    
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

extension ProductViewController: PHPickerViewControllerDelegate {
    
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
                        let controller = UIStoryboard(name: UploadBarcodeViewController.defaultNibName, bundle: .main).instantiateViewController(identifier: UploadBarcodeViewController.defaultNibName) { coder in
                            return UploadBarcodeViewController(coder: coder, chosenImage: image)
                        }
                        self.show(controller, sender: self)
                        
                        controller.barcodeStringPublisher
                            .sink { barcodeString in
                            self.queryForProduct(with: barcodeString)
                        }
                        .store(in: &self.cancellables)
                    } else {
                        self.showAlert(title: "Error", message: "Image could not be processed.")
                    }
                }
            }
        }
    }
}
