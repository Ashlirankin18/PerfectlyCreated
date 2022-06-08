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
    
    private enum DesignConstants {
        static let storeTitle = NSLocalizedString("Stores", comment: "Indicates to the user they can purchase products at these links.")
        static let notesTitle = NSLocalizedString("Notes", comment: "Indicates to the user they can use this field to add their notes.")
        static let errorTitle = NSLocalizedString("Error", comment: "Indicates to the user there was an error.")
        
        static let headerHeight: CGFloat = 44.0
        static let estimatedHeight: CGFloat = 50.0
        static let fractionalWidth: CGFloat = 1.0
        static let estimatedHeightItem: CGFloat = 500.0
        static let estimatedHeightGroup: CGFloat = 300.0
    }
    
    private enum SegueIdentifier {
        static let editProduct = "editProduct"
    }
    
    enum ProductType {
        case general
        case personal
    }
    
    private enum Section: Int, CaseIterable, Hashable {
        case aboutProduct
        case store
        case additionalInfo
    }
    
    private enum SectionData: Hashable {
        case productModel(ProductModel)
        case completed(Bool)
        case notes(String)
        case stores(Store)
    }
    
    @IBOutlet private weak var addProductBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var editExperienceButton: UIBarButtonItem!
    @IBOutlet private weak var backBarButtonItem: UIBarButtonItem!
    
    private let productType: ProductType
    private let productModel: ProductModel
    private var productInfoDraft = ProductInfoDraft()
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var productManager = ProductManager()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, SectionData> = UICollectionViewDiffableDataSource(collectionView: self.collectionView) { (_, indexPath, model) -> UICollectionViewCell? in
        return self.configureCell(model: model, indexPath: indexPath)
    }
    
    private let aboutProductCollectionLayoutSection: NSCollectionLayoutSection = {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(DesignConstants.estimatedHeightItem))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }()
    
    private let storeCollectionLayoutSection: NSCollectionLayoutSection = {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(DesignConstants.fractionalWidth), heightDimension: .estimated(DesignConstants.headerHeight))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: HeaderCollectionReusableView.nibName, alignment: .top)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75), heightDimension: .fractionalWidth(0.7))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        group.interItemSpacing = .flexible(0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.boundarySupplementaryItems = [sectionHeader]
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: .zero)
        section.interGroupSpacing = .zero
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        return section
    }()
    
    private let additionalInfoCollectionLayoutSection: NSCollectionLayoutSection = {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(DesignConstants.headerHeight))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: AdditionalCollectionReusableView.nibName, alignment: .top)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(DesignConstants.fractionalWidth), heightDimension: .estimated(DesignConstants.estimatedHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        
        group.interItemSpacing = .fixed(16.0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 24.0
        section.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }()
    
    private lazy var compositionalLayout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
        let sections = Section.allCases[sectionIndex]
        switch sections {
            case .aboutProduct:
                return self?.aboutProductCollectionLayoutSection
            case .additionalInfo:
                return self?.additionalInfoCollectionLayoutSection
            case .store:
                if self?.productModel.stores.isEmpty ?? true {
                    return nil
                } else {
                    return  self?.storeCollectionLayoutSection
                }
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
                editExperienceButton = nil
                reloadDataSource()
            case .personal:
                productManager.retrieveProduct(with: productModel.documentId) { [weak self] result in
                    switch result {
                        case let .failure(error):
                            print(error.localizedDescription)
                        case let .success(retrievedProduct):
                            self?.reloadDataSource(product: retrievedProduct)
                    }
                }
                
                editExperienceButton.tapPublisher.sink { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    self.performSegue(withIdentifier: SegueIdentifier.editProduct, sender: self)
                }
                .store(in: &cancellables)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.configuresShadowlessTransparentNavigationBar(backgroundColor: .clear)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func configureCollectionView() {
        collectionView.register(UINib(nibName: AboutProductCollectionViewCell.nibName, bundle: .main), forCellWithReuseIdentifier: AboutProductCollectionViewCell.nibName)
        collectionView.register(UINib(nibName: CompletedCollectionViewCell.nibName, bundle: .main), forCellWithReuseIdentifier: CompletedCollectionViewCell.nibName)
        collectionView.register(UINib(nibName: NotesCollectionViewCell.nibName, bundle: .main), forCellWithReuseIdentifier: NotesCollectionViewCell.nibName)
        collectionView.register(UINib(nibName: StoreCollectionViewCell.nibName, bundle: .main), forCellWithReuseIdentifier: StoreCollectionViewCell.nibName)
        collectionView.register(UINib(nibName: HeaderCollectionReusableView.nibName, bundle: .main), forSupplementaryViewOfKind: HeaderCollectionReusableView.nibName, withReuseIdentifier: HeaderCollectionReusableView.nibName)
        collectionView.register(UINib(nibName: AdditionalCollectionReusableView.nibName, bundle: .main), forSupplementaryViewOfKind: AdditionalCollectionReusableView.nibName, withReuseIdentifier: AdditionalCollectionReusableView.nibName)
        
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
                navigationItem.rightBarButtonItems?.first?.image = UIImage(systemName: "trash.fill")
                navigationItem.rightBarButtonItems?.first?.tintColor = .systemRed
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
                    self?.showAlert(title: DesignConstants.errorTitle, message: "An error occurred: \(error.localizedDescription)")
                case .success:
                    self?.productManager.addProduct(product: product) { [weak self] result in
                        guard let self = self else {
                            return
                        }
                        switch result {
                            case let .failure(error):
                                self.showAlert(title: DesignConstants.errorTitle, message: "An error occurred: \(error.localizedDescription)")
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
                    self?.showAlert(title: DesignConstants.errorTitle, message: "An error occurred: \(error.localizedDescription)")
                case .success:
                    self?.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    private func reloadDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SectionData>()
        snapshot.appendSections([.aboutProduct, .store, .additionalInfo])
        
        switch productType {
            case .general:
                snapshot.appendItems([.productModel(productModel)], toSection: .aboutProduct)
                productModel.stores.forEach { store in
                    snapshot.appendItems([.stores(store)], toSection: .store)
                }
            case .personal: break
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func reloadDataSource(product: ProductModel) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SectionData>()
        snapshot.appendSections([.aboutProduct, .store, .additionalInfo])
        
        productInfoDraft.documentId = product.documentId
        productInfoDraft.isCompleted = product.isCompleted
        productInfoDraft.notes = product.notes ?? NSLocalizedString("Tap edit to add note", comment: "Indicates that the edit button can be used to edit notes.")
        
        snapshot.appendItems([.productModel(product)], toSection: .aboutProduct)
        
        snapshot.appendItems([.completed(productInfoDraft.isCompleted)], toSection: .additionalInfo)
        
        let notes = productInfoDraft.notes
        snapshot.appendItems([.notes(notes)], toSection: .additionalInfo)
        
        if !product.stores.isEmpty {
            product.stores.forEach { store in
                snapshot.appendItems([.stores(store)], toSection: .store)
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureCell(model: SectionData, indexPath: IndexPath) -> UICollectionViewCell {
        switch model {
            case let .productModel(info):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AboutProductCollectionViewCell.nibName, for: indexPath) as? AboutProductCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.viewModel = AboutProductCollectionViewCell.ViewModel(productName: info.productName, productDescription: info.productDescription, imageURL: URL(string: info.productImageURL), category: info.category)
                return cell
            case let .completed(completed):
                guard let completedCell = collectionView.dequeueReusableCell(withReuseIdentifier: CompletedCollectionViewCell.nibName, for: indexPath) as? CompletedCollectionViewCell else {
                    return UICollectionViewCell()
                }
                completedCell.viewModel = CompletedCollectionViewCell.ViewModel(isCompleted: completed, title: NSLocalizedString("Product Complete", comment: "Indicates  that this product is complete"), configuration: .display)
                return completedCell
            case let .notes(notes):
                guard let notesCell = collectionView.dequeueReusableCell(withReuseIdentifier: NotesCollectionViewCell.nibName, for: indexPath) as? NotesCollectionViewCell else {
                    return UICollectionViewCell()
                }
                notesCell.viewModel = NotesCollectionViewCell.ViewModel(title: DesignConstants.notesTitle, notes: notes, configuration: .display)
                return notesCell
            case let .stores(store):
                guard let storeCell = collectionView.dequeueReusableCell(withReuseIdentifier: StoreCollectionViewCell.nibName, for: indexPath) as? StoreCollectionViewCell else {
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
                    
                    let section = Section.allCases[indexPath.section]
                    
                    switch section {
                        case .aboutProduct:
                            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: AdditionalCollectionReusableView.nibName, withReuseIdentifier: AdditionalCollectionReusableView.nibName, for: indexPath) as? AdditionalCollectionReusableView else {
                                return nil
                            }
                            header.isHidden = true
                            return header
                        case .additionalInfo:
                            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: AdditionalCollectionReusableView.nibName, withReuseIdentifier: AdditionalCollectionReusableView.nibName, for: indexPath) as? AdditionalCollectionReusableView else {
                                return nil
                            }
                            header.editButtonTapHandler = { [weak self] in
                                guard let self = self else {
                                    return
                                }
                                
                            }
                            return header
                        case .store:
                            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: HeaderCollectionReusableView.nibName, withReuseIdentifier: HeaderCollectionReusableView.nibName, for: indexPath) as? HeaderCollectionReusableView else {
                                return nil
                            }
                            
                            header.viewModel = .init(title: DesignConstants.storeTitle)
                            return header
                    }
                case .general:
                    let section = Section.allCases[indexPath.section]
                    
                    guard let new = collectionView.dequeueReusableSupplementaryView(ofKind: AdditionalCollectionReusableView.nibName, withReuseIdentifier: AdditionalCollectionReusableView.nibName, for: indexPath) as? AdditionalCollectionReusableView else {
                        return nil
                    }
                    
                   //new.viewModel = .init(title: DesignConstants.storeTitle)//
                    
                    switch section {
                        case .aboutProduct, .additionalInfo:
                            new.isHidden = true
                        case .store:
                            if self.productModel.stores.isEmpty {
                                new.isHidden = true
                            } else {
                                new.isHidden = false
                            }
                    }
                return new
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
            case .aboutProduct: break
            case .additionalInfo: break
            case .store:
                let store = productModel.stores[indexPath.row]
                guard let url = URL(string: store.link) else {
                    return
                }
                let controller = SFSafariViewController(url: url)
                present(controller, animated: true)
        }
    }
}
