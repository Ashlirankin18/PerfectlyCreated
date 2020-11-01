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
        navigationItem.searchController = searchController
        productTableView.register(ProductDisplayCell.self, forCellReuseIdentifier: "ProductDisplayCell")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allHairProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = productTableView.dequeueReusableCell(withIdentifier: "ProductDisplayCell", for: indexPath) as? ProductDisplayCell else {
            fatalError("no product display cell found")
        }
        let hairProduct = allHairProducts[indexPath.row]
        let urlString = hairProduct.results.images.first?.absoluteString ?? "no string found"
        cell.productName.text = hairProduct.results.name.capitalized
        cell.categoryLabel.text = hairProduct.results.category
        getImage(ImageView: cell.productImage, imageURLString: urlString)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productController = ShowProductViewController.init(hairProduct: allHairProducts[indexPath.row], view: HairProductView())
        let navigationController = UINavigationController(rootViewController: productController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension SearchProductViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
}

extension SearchProductViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            print("no text found")
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
