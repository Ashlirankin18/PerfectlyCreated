//
//  HairProductsTableViewController.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/28/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit
import FirebaseFirestore

import Firebase
protocol HairProductsTableViewControllerDelegate:AnyObject {
    func sendSelectedProduct(_ controller:HairProductsTableViewController,selectedProduct: ProductModel)
}

class HairProductsTableViewController: UITableViewController {
    
    weak var delegate: HairProductsTableViewControllerDelegate?
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    private var userProducts = [ProductModel](){
        didSet{
            DispatchQueue.main.async {
                self.dict = Dictionary.init(grouping: self.userProducts, by: {$0.category})
            }
        }
    }
    
    private var dict: [String : [ProductModel]] = [:] {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private var userSession: UserSession!
    private var selectedProduct: ProductModel?
   
    var allHairProducts = [AllHairProducts]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userSession = AppDelegate.userSession
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.dataSource = self
        getUserProducts()
        allHairProducts =  ProductDataManager.getProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    @IBAction func completedButtonPressed(_ sender: UIButton) {
        if (sender.currentImage?.isEqual(#imageLiteral(resourceName: "icons8-checked-filled-25.png")))!{
            sender.setImage(#imageLiteral(resourceName: "icons8-checked-filled-25 (1)"), for: .normal)
            if var selectedProduct = selectedProduct{
                selectedProduct.isCompleted = true
                DataBaseManager.updateCompletionStatus(product: selectedProduct)
                sender.isEnabled = false
            }
        }else{
            sender.setImage(#imageLiteral(resourceName: "icons8-checked-filled-25.png"), for: .normal)
            if var selectedProduct = selectedProduct {
                selectedProduct.isCompleted = false
                DataBaseManager.updateCompletionStatus(product: selectedProduct)
                sender.isEnabled = false
            }
            
        }
    }
    
    private func getUserProducts(){
        if let user = userSession.getCurrentUser(){
            let documentReference = DataBaseManager.firebaseDB.collection(FirebaseCollectionKeys.products)
            documentReference.addSnapshotListener(includeMetadataChanges: true) { [weak self] (snapshot, error) in
                if let error = error{
                    print("the error was: \(error)")
                }else if let snapshot = snapshot {
                    let qurey = snapshot.query.whereField("userId", isEqualTo: user.uid)
                    qurey.getDocuments(completion: { (snapshot, error) in
                        if let error = error{
                            print(error.localizedDescription)
                        } else if let snapshot = snapshot{
                            let document = snapshot.documents
                            self?.userProducts.removeAll()
                            document.forEach {_ in
                                
                            }
                        }
                    })
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitles = Array(dict.keys)
        
        if let value = dict[sectionTitles[section]] {
            return value.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(integerLiteral: 220)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titles = Array(dict.keys)
        return titles[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dict.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? HairTableViewCell else {fatalError("no product cell found")}
        cell.shareProduct.tag = indexPath.row
        let sectionTitles = Array(dict.keys)
        if let values = dict[sectionTitles[indexPath.section]]{
            let product = values[indexPath.row]
            getImage(imageView: cell.productImage, imageURLString: product.productImageURL)
            cell.productName.text = product.productName
            if product.isCompleted == true{
                cell.shareProduct.setImage(#imageLiteral(resourceName: "icons8-checked-filled-25 (1).png"), for: .normal)
                cell.shareProduct.isEnabled = false
            }else{
                cell.shareProduct.setImage(#imageLiteral(resourceName: "icons8-checked-filled-25.png"), for: .normal)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? HairTableViewCell else {fatalError("no hair cell found")}
        
        let section = Array(dict.keys)
        if let values = dict[section[indexPath.section]]{
            guard values.count != 0 else {return}
            let shareButtonIndex = cell.shareProduct.tag
            let product = values[shareButtonIndex]
            self.selectedProduct = product
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let section = Array(self.dict.keys)
            guard let values = self.dict[section[indexPath.section]] else {return}
            let product = values[indexPath.row]
            DataBaseManager.deleteDocumentFromDatabase(product: product)
        }
        
        let share = UITableViewRowAction(style: .normal, title: "Share") { (action, indexPath) in
            let storyBoard = UIStoryboard.init(name: "ProfileOptions", bundle: nil)
            guard let postViewController = storyBoard.instantiateViewController(withIdentifier: "PostFeedViewController") as? PostFeedViewController else {return}
            if let selectedProduct = self.selectedProduct{
                postViewController.sendSelectedProduct(self, selectedProduct: selectedProduct)
            }
            
            self.present(postViewController, animated: true)
        }
        
        share.backgroundColor = UIColor.lightGray
        return [delete, share]
    }
}
