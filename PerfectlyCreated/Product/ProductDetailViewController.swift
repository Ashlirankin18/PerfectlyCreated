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

/// <#Description#>
final class ProductDetailViewController: UICollectionViewController {
    
    private enum SegueIdentifier {
        static let editProduct = "editProduct"
    }
    
    enum ProductType {
        case personal(ProductModel)
        case general(AllHairProducts)
        case newApi(HairProduct)
    }
    
    private enum Section: Int, CaseIterable, Hashable {
        case aboutProduct
        case additionalInfo
        case newApi
    }
    
    private enum SectionData: Hashable {
        case aboutProduct(HairProductDetails)
        case additionalInfo(ProductModel)
        case newApi(HairProduct)
    }
    
    private enum SectionDataTest: Hashable {
        case productModel(SectionData)
        case completed(Bool)
        case notes(String)
        case stores(Store)
    }
    
    @IBOutlet private weak var addProductBarButtonItem: UIBarButtonItem!
    
    @IBOutlet private weak var backBarButtonItem: UIBarButtonItem!
    
    private let productType: ProductType
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var productManager = ProductManager()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, SectionDataTest> = UICollectionViewDiffableDataSource(collectionView: self.collectionView) { (_, indexPath, model) -> UICollectionViewCell? in
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
        section.orthogonalScrollingBehavior = .continuous
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
        case .aboutProduct, .newApi:
            return self.aboutProductCollectionLayoutSection
        case .additionalInfo:
            return self.additionalInfoCollectionLayoutSection
        }
    }
    
    /// Creates a new instance of `ProductDetailViewController`.
    /// - Parameters:
    ///   - coder: An abstract class that serves as the basis for objects that enable archiving and distribution of other objects.
    ///   - productType: The type of product.
    init?(coder: NSCoder, productType: ProductType) {
        self.productType = productType
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
        case .general, .newApi:
            reloadDataSource()
        case let .personal(product):
            productManager.retrieveProduct(with: product.documentId) { result in
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
        collectionView.register(UINib(nibName: AdditionalCollectionReusableView.defaultNibName, bundle: .main), forSupplementaryViewOfKind: AdditionalCollectionReusableView.defaultNibName, withReuseIdentifier: AdditionalCollectionReusableView.defaultNibName)
        collectionView.register(UINib(nibName: StoreCollectionViewCell.defaultNibName, bundle: .main), forCellWithReuseIdentifier: StoreCollectionViewCell.defaultNibName)
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
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        switch productType {
        case let .general(product):
            
            let model = product.results
            
            let product = ProductModel(productName: model.name, documentId: productManager.documentId, productDescription: model.features?.blob ?? model.description, userId: currentUser.uid, productImageURL: model.images.first?.absoluteString ?? "", category: model.category, isCompleted: false, notes: nil, stores: [])
            
            addProductBarButtonItem.tapPublisher.sink { [weak self]  _ in
                guard let self = self else {
                    return
                }
                
                self.productManager.addProduct(product: product) { [weak self] result in
                    guard let self = self else {
                        return
                    }
                    
                    switch result {
                    case let .failure(error):
                        print(error)
                    case .success:
                        self.dismiss(animated: true)
                    }
                }
            }
            .store(in: &cancellables)
            
        case let .personal(product):
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "trash.fill")
            navigationItem.rightBarButtonItem?.tintColor = .systemRed
            
            addProductBarButtonItem.tapPublisher.sink { [weak self] _ in
                self?.persentDestructiveAlertController(title: nil, message: "Are you sure you want to delete this product?", destructiveTitle: "Delete", destructiveCompletion: {
                    self?.performDeleteAction(product: product)
                }, nonDestructiveTitle: "Keep")
            }
            .store(in: &cancellables)
        case let .newApi(product):
            let newProduct = ProductModel(productName: product.itemAttributes.title, documentId: productManager.documentId, productDescription: product.itemAttributes.itemAttributesDescription, userId: currentUser.uid, productImageURL: product.itemAttributes.image, category: product.itemAttributes.category, isCompleted: false, notes: nil, stores: product.stores)
            
            addProductBarButtonItem.tapPublisher.sink { [weak self]  _ in
                guard let self = self else {
                    return
                }
                
                self.productManager.addProduct(product: newProduct) { [weak self] result in
                    guard let self = self else {
                        return
                    }
                    
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
        var snapshot = NSDiffableDataSourceSnapshot<Section, SectionDataTest>()
        snapshot.appendSections([.aboutProduct, .additionalInfo])
        
        switch productType {
        case let .general(product):
            snapshot.appendItems([.productModel(.aboutProduct(product.results))], toSection: .aboutProduct)
        case .personal: break
        case let .newApi(product):
            snapshot.appendItems([.productModel(.newApi(product))], toSection: .aboutProduct)
            product.stores.forEach { store in
                snapshot.appendItems([.stores(store)], toSection: .additionalInfo)
            }
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func reloadDataSource(product: ProductModel) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SectionDataTest>()
        snapshot.appendSections([.aboutProduct, .additionalInfo])
        
        productInfoDraft.documentId = product.documentId
        productInfoDraft.isCompleted = product.isCompleted
        productInfoDraft.notes = product.notes ?? "Tap edit to add note"
        
        snapshot.appendItems([.productModel(.additionalInfo(product))], toSection: .aboutProduct)
        
        snapshot.appendItems([.completed(productInfoDraft.isCompleted)], toSection: .additionalInfo)
        
        let notes = productInfoDraft.notes
        snapshot.appendItems([.notes(notes)], toSection: .additionalInfo)
        
        product.stores.forEach { store in
            snapshot.appendItems([.stores(store)], toSection: .additionalInfo)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureCell(model: SectionDataTest, indexPath: IndexPath) -> UICollectionViewCell {
        
        switch model {
        case let .productModel(sectionData):
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AboutProductCollectionViewCell", for: indexPath) as? AboutProductCollectionViewCell else {
                return UICollectionViewCell()
            }
            switch sectionData {
            case let .aboutProduct(info):
                cell.viewModel = AboutProductCollectionViewCell.ViewModel(productName: info.name, productDescription: info.features?.blob ?? info.description, imageURL: info.images.first, category: info.category)
            case let .additionalInfo(product):
                cell.viewModel = AboutProductCollectionViewCell.ViewModel(productName: product.productName, productDescription: product.productDescription, imageURL: URL(string: product.productImageURL), category: product.category)
            case let .newApi(product):
                cell.viewModel = AboutProductCollectionViewCell.ViewModel(productName: product.itemAttributes.title, productDescription: product.itemAttributes.itemAttributesDescription, imageURL: URL(string: product.itemAttributes.image), category: product.itemAttributes.category)
            }
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
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            switch self.productType {
            case .personal:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: AdditionalCollectionReusableView.defaultNibName, withReuseIdentifier: AdditionalCollectionReusableView.defaultNibName, for: indexPath) as? AdditionalCollectionReusableView else {
                    return nil
                }
                
                header.editButtonTapHandler = {
                    self.performSegue(withIdentifier: SegueIdentifier.editProduct, sender: self)
                }
                return header
            case .general, .newApi:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: AdditionalCollectionReusableView.defaultNibName, withReuseIdentifier: AdditionalCollectionReusableView.defaultNibName, for: indexPath) as? AdditionalCollectionReusableView else {
                    return nil
                }
                header.isHidden = true
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
        case .newApi: return nil
        }
    }
}
