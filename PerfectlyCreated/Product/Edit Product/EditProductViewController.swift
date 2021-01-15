//
//  EditProductViewController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 12/18/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit
import Combine

/// `UIViewController` subclass which allows a user to edit their profile.
final class EditProductViewController: UIViewController {
    
    private enum Section: Hashable {
        case info
        case notes
    }
    
    private enum SectionData: Hashable {
        case info(Bool)
        case notes(String)
    }
    
    @IBOutlet private weak var editProductCollectionView: UICollectionView!
    @IBOutlet private weak var backBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var saveBarButtonItem: UIBarButtonItem!
    
    private lazy var editProductDataSource: UICollectionViewDiffableDataSource<Section, SectionData> = UICollectionViewDiffableDataSource(collectionView: self.editProductCollectionView) { collectionView, indexPath, model  in
        return self.configureCell(collectionView: collectionView, model: model, indexPath: indexPath)
    }
    
    private var coloredAppearance: UINavigationBarAppearance {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = .systemIndigo
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.shadowColor = .clear
        return coloredAppearance
    }
    
    private let additionalInfoCollectionLayoutSection: NSCollectionLayoutSection = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        return section
    }()
    
    private let productInfoDraft: ProductInfoDraft
    
    private var cancellables = Set<AnyCancellable>()
    
    private let productManager: ProductManager
    
    init?(coder: NSCoder, productInfoDraft: ProductInfoDraft, productManager: ProductManager) {
        self.productInfoDraft = productInfoDraft
        self.productManager = productManager
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemIndigo
        editProductCollectionView.backgroundColor = .systemIndigo
        configureNavBar()
        configureBackButton()
        configureSaveBarButton()
        configureCollectionView()
        configureLayout()
        reloadDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureCollectionView() {
        editProductCollectionView.register(UINib(nibName: CompletedCollectionViewCell.defaultNibName, bundle: .main), forCellWithReuseIdentifier: CompletedCollectionViewCell.defaultNibName)
        editProductCollectionView.register(UINib(nibName: NotesCollectionViewCell.defaultNibName, bundle: .main), forCellWithReuseIdentifier: NotesCollectionViewCell.defaultNibName)
    }
    
    private func configureNavBar() {
        title = "Edit Product"
        navigationController?.navigationBar.standardAppearance = coloredAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = coloredAppearance
    }
    
    private func configureLayout() {
        let layout = UICollectionViewCompositionalLayout(section: additionalInfoCollectionLayoutSection)
        editProductCollectionView.collectionViewLayout = layout
    }
    
    private func configureSaveBarButton() {
        saveBarButtonItem.tapPublisher.sink { [weak self] _ in
            guard let self = self else {
                return
            }
            
            let productFieldsToUpdate: [String: Any] = [ "notes": self.productInfoDraft.notes , "isCompleted": self.productInfoDraft.isCompleted]
            
            self.productManager.updateProduct(documentId: self.productInfoDraft.documentId, productFields: productFieldsToUpdate) { result in
                switch result {
                    case let .failure(error):
                        self.showAlert(title: "Error!", message: "\(error.localizedDescription)")
                    case .success:
                        self.navigationController?.popViewController(animated: true)
                }
            }
        }
        .store(in: &cancellables)
    }
    
    private func configureBackButton() {
        backBarButtonItem.tapPublisher.sink { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        .store(in: &cancellables)
    }

    private func configureCell(collectionView: UICollectionView, model: SectionData, indexPath: IndexPath) -> UICollectionViewCell {
        
        switch model {
            case let .info(isCompleted):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompletedCollectionViewCell.defaultNibName, for: indexPath) as? CompletedCollectionViewCell else {
                    return  UICollectionViewCell()
                }
                
                cell.viewModel = .init(isCompleted: isCompleted, title: "Is Completed?", configuration: .editing)
                
                cell.isCompletePublisher.sink { isCompleted in
                    self.productInfoDraft.isCompleted = isCompleted
                }
                .store(in: &cancellables)
                
                return cell
            case let .notes(notes):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NotesCollectionViewCell.defaultNibName, for: indexPath) as? NotesCollectionViewCell else {
                    return  UICollectionViewCell()
                }
                
                cell.viewModel = .init(title: "Add notes here.", notes: notes, configuration: .editing)
                
                cell.textViewTextDidChangePublisher.sink { [weak self] _ in
                    self?.editProductCollectionView.collectionViewLayout.invalidateLayout()
                }
                .store(in: &cancellables)
                
                cell.notesTextHandler = { text in
                    self.productInfoDraft.notes = text ?? ""
                }
                return cell
        }
    }
    
    private func reloadDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SectionData>()
        snapshot.appendSections([.info, .notes])
        snapshot.appendItems([.info(productInfoDraft.isCompleted)], toSection: .info)
        snapshot.appendItems([.notes(productInfoDraft.notes)], toSection: .notes)
        editProductDataSource.apply(snapshot)
    }
}
