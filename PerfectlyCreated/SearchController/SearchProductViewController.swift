//
//  SearchProductViewController.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/20/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit
import CombineCocoa
import Combine

final class SearchProductViewController: UIViewController {
    
    @IBOutlet private weak var dismissBarButtonItem: UIBarButtonItem!
    @IBOutlet private var productTableView: UITableView!
    
    private var allHairProducts = [AllHairProducts]() {
        didSet{
            DispatchQueue.main.async {
                self.navigationItem.title = "\(self.allHairProducts.count) Products"
                self.productTableView.reloadData()
            }
        }
    }
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.tintColor = .white
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.backgroundColor = .white
        searchController.isAccessibilityElement = true
        searchController.searchBar.isAccessibilityElement = true
        searchController.searchBar.accessibilityLabel = NSLocalizedString("Search Bar", comment: "Indicates to the user that this object is a search bar")
        searchController.accessibilityLabel = NSLocalizedString("Search Controller", comment: "Indicates to the user that this object is a search controller")
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productTableView.register(ProductDisplayCell.self, forCellReuseIdentifier: "ProductDisplayCell")
        configureNavigationItemProperties()
        setDelegates()
        configureDismissButtonHandler()
    }
    
    private func setDelegates() {
        productTableView.dataSource = self
        productTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.allHairProducts = ProductDataManager.getProducts().sorted{$0.results.name < $1.results.name}
    }
    
    private func configureNavigationItemProperties() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func configureDismissButtonHandler() {
        dismissBarButtonItem.tapPublisher.sink {
            self.dismiss(animated: true)
        }
        .store(in: &cancellables)
    }
    
    @objc private func backButtonPressed() {
        self.dismiss(animated: true)
    }
}

extension SearchProductViewController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allHairProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = productTableView.dequeueReusableCell(withIdentifier: "ProductDisplayCell", for: indexPath) as? ProductDisplayCell else {
            fatalError("no product display cell found")
        }
        let hairProduct = allHairProducts[indexPath.row]
        cell.productName.text = hairProduct.results.name.capitalized
        cell.categoryLabel.text = hairProduct.results.category
        cell.productImage.kf.setImage(with: hairProduct.results.images.first)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let productController =
            UIStoryboard(name: ProductDetailViewController.defaultNibName, bundle: .main).instantiateViewController(identifier: ProductDetailViewController.defaultNibName) { coder in
            return ProductDetailViewController(coder: coder, productType: .general(self.allHairProducts[indexPath.row]))
        }
        
        self.navigationController?.pushViewController(productController, animated: true)
    }
}

extension SearchProductViewController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension SearchProductViewController: UISearchResultsUpdating {
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        
        if searchText.isEmpty {
            allHairProducts = ProductDataManager.getProducts()
        } else {
            let anArray = allHairProducts.filter({$0.results.name.contains(searchText.capitalized)})
            allHairProducts = anArray.sorted{$0.results.name < $1.results.name}
            self.navigationItem.title = "\(allHairProducts.count) Products"
        }
    }
}
