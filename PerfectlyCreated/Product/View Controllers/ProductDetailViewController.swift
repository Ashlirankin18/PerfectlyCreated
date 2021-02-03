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
import SafariServices

/// `UIViewController` subclass which displays the details of a product.
final class ProductDetailViewController: UICollectionViewController {
    
    private enum SegueIdentifier {
        static let editProduct = "editProduct"
    }
    
    enum ProductType {
        case general
        case personal
    }
    
    private enum Section: Int, CaseIterable, Hashable {
        case aboutProduct
        case additionalInfo
    }
    
    private enum SectionData: Hashable {
        case productModel(ProductModel)
        case completed(Bool)
        case notes(String)
        case stores(Store)
    }
    
    @IBOutlet private weak var addProductBarButtonItem: UIBarButtonItem!
    
    @IBOutlet private weak var backBarButtonItem: UIBarButtonItem!
    
    private let productType: ProductType
    
    private let productModel: ProductModel
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var productManager = ProductManager()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, SectionData> = UICollectionViewDiffableDataSource(collectionView: self.collectionView) { (_, indexPath, model) -> UICollectionViewCell? in
        return self.configureCell(model: model, indexPath: indexPath)
    }
    
    private var productInfoDraft = ProductInfoDraft()
    
    private let aboutProductCollectionLayoutSection: NSCollectionLayoutSection = {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: AdditionalCollectionReusableView.defaultNibName, alignment: .bottom)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        return section
    }()
    
    private let additionalInfoCollectionLayoutSection: NSCollectionLayoutSection = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }()
    
    private lazy var compositionalLayout = UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        let sections = Section.allCases[sectionIndex]
        switch sections {
        case .aboutProduct:
                return self.aboutProductCollectionLayoutSection
        case .additionalInfo:
                return self.additionalInfoCollectionLayoutSection
        }
    }
    
    /// Creates a new instance of `ProductDetailViewController`.
    /// - Parameters:
    ///   - coder: An abstract class that serves as the basis for objects that enable archiving and distribution of other objects.
    ///   - productType: The type of product.
    init?(coder: NSCoder, productType: ProductType, productModel: ProductModel) {
        self.productType = productType
        self.productModel = productModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBarButtonTapHandler()
        configureBackButtonItem()
        configureCollectionView()
        configureHeaders()
        
        switch productType {
        case .general:
                reloadDataSource()
        case .personal:
            productManager.retrieveProduct(with: productModel.documentId) { result in
                switch result {
                case let .failure(error):
                    print(error.localizedDescription)
                case let .success(retrievedProduct):
                    self.reloadDataSource(product: retrievedProduct)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.configuresShadowlessTransparentNavigationBar(backgroundColor: .clear)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func configureCollectionView() {
        collectionView.register(UINib(nibName: AboutProductCollectionViewCell.defaultNibName, bundle: .main), forCellWithReuseIdentifier: AboutProductCollectionViewCell.defaultNibName)
        collectionView.register(UINib(nibName: CompletedCollectionViewCell.defaultNibName, bundle: .main), forCellWithReuseIdentifier: CompletedCollectionViewCell.defaultNibName)
        collectionView.register(UINib(nibName: NotesCollectionViewCell.defaultNibName, bundle: .main), forCellWithReuseIdentifier: NotesCollectionViewCell.defaultNibName)
        collectionView.register(UINib(nibName: StoreCollectionViewCell.defaultNibName, bundle: .main), forCellWithReuseIdentifier: StoreCollectionViewCell.defaultNibName)
        collectionView.register(UINib(nibName: HeaderCollectionReusableView.defaultNibName, bundle: .main), forSupplementaryViewOfKind: HeaderCollectionReusableView.defaultNibName, withReuseIdentifier: HeaderCollectionReusableView.defaultNibName)
        collectionView.register(UINib(nibName: AdditionalCollectionReusableView.defaultNibName, bundle: .main), forSupplementaryViewOfKind: AdditionalCollectionReusableView.defaultNibName, withReuseIdentifier: AdditionalCollectionReusableView.defaultNibName)
        
        collectionView.collectionViewLayout = compositionalLayout
        collectionView.dataSource = dataSource
    }
    
    private func configureBackButtonItem() {
        backBarButtonItem.tapPublisher.sink { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        .store(in: &cancellables)
    }
    
    private func configureBarButtonTapHandler() {        
        switch productType {
        case .general:
            addProductBarButtonItem.tapPublisher.sink { [weak self]  _ in
                guard let self = self else {
                    return
                }
                self.addProductToDatabase(product: self.productModel)
            }
            .store(in: &cancellables)
            
        case  .personal:
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "trash.fill")
            navigationItem.rightBarButtonItem?.tintColor = .systemRed
            
            addProductBarButtonItem.tapPublisher.sink { [weak self] _ in
                
                guard let self = self else {
                    return
                }
                self.persentDestructiveAlertController(title: nil, message: "Are you sure you want to delete this product?", destructiveTitle: "Delete", destructiveCompletion: {
                    self.performDeleteAction(product: self.productModel)
                }, nonDestructiveTitle: "Keep")
            }
            .store(in: &cancellables)
        }
    }
    
    private func addProductToDatabase(product: ProductModel) {
        productManager.validateProductCollection(upc: product.upc) { [weak self] result in
            switch result {
            case let .failure(error):
                self?.showAlert(title: "Error", message: "An error occurred: \(error.localizedDescription)")
            case .success:
                self?.productManager.addProduct(product: product) { [weak self] result in
                    guard let self = self else {
                        return
                    }
                    switch result {
                    case let .failure(error):
                        self.showAlert(title: "Error", message: "An error occurred: \(error.localizedDescription)")
                    case .success:
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    private func performDeleteAction(product: ProductModel) {
        productManager.deleteProduct(product, completionHandler: { [weak self] result in
            switch result {
            case let .failure(error):
                self?.showAlert(title: "Error", message: "An error occurred: \(error.localizedDescription)")
            case .success:
                self?.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    private func reloadDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SectionData>()
        snapshot.appendSections([.aboutProduct, .additionalInfo])
        
        switch productType {
        case .general:
            snapshot.appendItems([.productModel(productModel)], toSection: .aboutProduct)
            productModel.stores.forEach { store in
                snapshot.appendItems([.stores(store)], toSection: .additionalInfo)
            }
        case .personal: break
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func reloadDataSource(product: ProductModel) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SectionData>()
        snapshot.appendSections([.aboutProduct, .additionalInfo])
        
        productInfoDraft.documentId = product.documentId
        productInfoDraft.isCompleted = product.isCompleted
        productInfoDraft.notes = product.notes ?? "Tap edit to add note"
        
        snapshot.appendItems([.productModel(product)], toSection: .aboutProduct)
        
        snapshot.appendItems([.completed(productInfoDraft.isCompleted)], toSection: .additionalInfo)
        
        let notes = productInfoDraft.notes
        snapshot.appendItems([.notes(notes)], toSection: .additionalInfo)
        
        product.stores.forEach { store in
            snapshot.appendItems([.stores(store)], toSection: .additionalInfo)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureCell(model: SectionData, indexPath: IndexPath) -> UICollectionViewCell {
        
        switch model {
        case let .productModel(info):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AboutProductCollectionViewCell", for: indexPath) as? AboutProductCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.viewModel = AboutProductCollectionViewCell.ViewModel(productName: info.productName, productDescription: info.productDescription, imageURL: URL(string: info.productImageURL), category: info.category)
                return cell
        case let .completed(completed):
            guard let completedCell = collectionView.dequeueReusableCell(withReuseIdentifier: CompletedCollectionViewCell.defaultNibName, for: indexPath) as? CompletedCollectionViewCell else {
                return UICollectionViewCell()
            }
            completedCell.viewModel = CompletedCollectionViewCell.ViewModel(isCompleted: completed, title: "Product Complete", configuration: .display)
            return completedCell
        case let .notes(notes):
            guard let notesCell = collectionView.dequeueReusableCell(withReuseIdentifier: NotesCollectionViewCell.defaultNibName, for: indexPath) as? NotesCollectionViewCell else {
                return UICollectionViewCell()
            }
            notesCell.viewModel = NotesCollectionViewCell.ViewModel(title: "Notes", notes: notes, configuration: .display)
            return notesCell
        case let .stores(store):
            guard let storeCell = collectionView.dequeueReusableCell(withReuseIdentifier: StoreCollectionViewCell.defaultNibName, for: indexPath) as? StoreCollectionViewCell else {
                return UICollectionViewCell()
            }
            guard let url = URL(string: store.image) else {
                return UICollectionViewCell()
            }
            storeCell.viewModel = StoreCollectionViewCell.ViewModel(imageURL: url, productName: store.title, storeName: store.storeName, price: "\(store.currency)\(store.price)")
            return storeCell
        }
    }
    
    private func configureHeaders() {
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, _, indexPath: IndexPath) -> UICollectionReusableView? in
            
            switch self.productType {
            case .personal:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: AdditionalCollectionReusableView.defaultNibName, withReuseIdentifier: AdditionalCollectionReusableView.defaultNibName, for: indexPath) as? AdditionalCollectionReusableView else {
                    return nil
                }
                
                header.editButtonTapHandler = {
                    self.performSegue(withIdentifier: SegueIdentifier.editProduct, sender: self)
                }
                return header
            case .general:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: HeaderCollectionReusableView.defaultNibName, withReuseIdentifier: HeaderCollectionReusableView.defaultNibName, for: indexPath) as? HeaderCollectionReusableView else {
                    return nil
                }
                
                header.titleLabel.text = "Stores"
                return header
            }
        }
    }
    
    @IBSegueAction
    private func makeEditViewController(coder: NSCoder) -> EditProductViewController? {
        switch productType {
        case .general: return nil
        case .personal:
            let controller = EditProductViewController(coder: coder, productInfoDraft: productInfoDraft, productManager: productManager)
            return controller
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = Section.allCases[indexPath.section]
        
        switch section {
        case .aboutProduct:
            let store = productModel.stores[indexPath.row]
            guard let url = URL(string: store.link) else {
                return
            }
            let controller = SFSafariViewController(url: url)
            present(controller, animated: true)
        case .additionalInfo:
            let store = productModel.stores[indexPath.row - 2]
            guard let url = URL(string: store.link) else {
                return
            }
            let controller = SFSafariViewController(url: url)
            present(controller, animated: true)
        }
    }
}
