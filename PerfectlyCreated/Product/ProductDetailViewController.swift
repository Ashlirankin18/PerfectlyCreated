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

final class ProductDetailViewController: UICollectionViewController {
    
    enum ProductType {
        case personal(ProductModel)
        case general(AllHairProducts)
    }
    
    enum Section: Int, Hashable {
        case aboutProduct
        case additionalInfo
    }
    
    enum SectionData: Hashable {
        case aboutProduct(HairProductDetails)
        case additionalInfo(ProductModel)
    }
    
    @IBOutlet private weak var addProductBarButtonItem: UIBarButtonItem!
    
    private let productType: ProductType
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var productManager = ProductManager()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, SectionData> = UICollectionViewDiffableDataSource(collectionView: self.collectionView) { (_, indexPath, model) -> UICollectionViewCell? in
        return self.configureCell(model: model, indexPath: indexPath)
    }
    
    private let aboutProductCollectionLayoutSection: NSCollectionLayoutSection = {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: AdditionalCollectionReusableView.defaultNibName, alignment: .bottom)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        return section
    }()
    
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
        configureCollectionView()
        configureHeaders()
        reloadDataSource()
        
    }
    
    private func configureCollectionView() {
        collectionView.register(UINib(nibName: AboutProductCollectionViewCell.defaultNibName, bundle: .main), forCellWithReuseIdentifier: AboutProductCollectionViewCell.defaultNibName)
        collectionView.register(UINib(nibName: AdditionalCollectionReusableView.defaultNibName, bundle: .main), forSupplementaryViewOfKind: AdditionalCollectionReusableView.defaultNibName, withReuseIdentifier: AdditionalCollectionReusableView.defaultNibName)
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: aboutProductCollectionLayoutSection)
        collectionView.dataSource = dataSource
    }
    
    private func configureBarButtonTapHandler() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        switch productType {
        case let .general(product):
            
            let model = product.results
            
            let product = ProductModel(productName: model.name, documentId: productManager.documentId, productDescription: model.features?.blob ?? model.description, userId: currentUser.uid, productImageURL: model.images.first?.absoluteString ?? "", category: model.category, isCompleted: false)
            
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
            addProductBarButtonItem = nil
        }
    }
    
    private func reloadDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SectionData>()
        snapshot.appendSections([.aboutProduct])
        
        switch productType {
        case let .general(product):
            snapshot.appendItems([.aboutProduct(product.results)], toSection: .aboutProduct)
        case let .personal(product):
            snapshot.appendItems([.additionalInfo(product)], toSection: .aboutProduct)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureCell(model: SectionData, indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AboutProductCollectionViewCell", for: indexPath) as? AboutProductCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        switch model {
        case let .aboutProduct(info):
            cell.viewModel = AboutProductCollectionViewCell.ViewModel(productName: info.name, productDescription: info.features?.blob ?? info.description, productURL: info.images.first)
        case let .additionalInfo(product):
            cell.viewModel = AboutProductCollectionViewCell.ViewModel(productName: product.productName, productDescription: product.productDescription, productURL: URL(string: product.productImageURL))
        }
        return cell
    }
    
    private func configureHeaders() {
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            guard let section = Section(rawValue: indexPath.section) else {
                return nil
            }
            
            switch section {
            case .aboutProduct:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: AdditionalCollectionReusableView.defaultNibName, withReuseIdentifier: AdditionalCollectionReusableView.defaultNibName, for: indexPath) as? AdditionalCollectionReusableView else {
                    return nil
                }
                
                header.editButtonTapHandler = {
                    
                }
                return header
            case .additionalInfo:
                return UICollectionReusableView()
            }
        }
    }
}
