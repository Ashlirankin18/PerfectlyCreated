//
//  PopUpViewController.swift
//  PerfectlyCrafted
//
//  Created by Ashli Rankin on 2/18/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit
import Firebase

class PopUpViewController: UIViewController {
  
 private let popUpView = PopUpView()
  private var imagePickerController: UIImagePickerController!

  var allHairProducts = [AllHairProducts](){
    didSet{
      allHairProducts.sort{$0.results.name < $1.results.name}
    }
  }
  var tapGesture: UITapGestureRecognizer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(popUpView)
    view.backgroundColor = .clear
    setUpImagePickerController()
    addingActionsToButtons()
    setUpTapGesture()
  }
  func setUpTapGesture(){
    tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopUp))
    self.view.addGestureRecognizer(tapGesture)
  }
  @objc func dismissPopUp(){
    self.dismiss(animated: true)
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.allHairProducts = ProductDataManager.getProducts()
  }
  func addingActionsToButtons(){
    popUpView.addFromCameraButton.addTarget(self, action: #selector(presentCameraOption), for: .touchUpInside)
    popUpView.addFromGalleryButton.addTarget(self, action: #selector(presentGalleryOption), for: .touchUpInside)
    popUpView.searchForProductButton.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
  }
  private func setUpImagePickerController(){
    imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    
  }
  private func showImagePickerController(){
    self.present(imagePickerController, animated: true, completion: nil)
  }

    func getProductFromBarcode(barcodeNumber:String) -> AllHairProducts? {
      let product = allHairProducts.first{$0.results.upc == barcodeNumber}
      return product
    }
  
  
  private func openCamera(){
    if UIImagePickerController.isSourceTypeAvailable(.camera){
      let myPickerController = UIImagePickerController()
      myPickerController.delegate = self
      myPickerController.sourceType = .camera
      present(myPickerController, animated: true, completion: nil)
    }
  }
 
  
 @objc private func presentCameraOption(){
    openCamera()
  }
 @objc private func presentGalleryOption(){
    showImagePickerController()
  }
  @objc private func searchButtonPressed(){
    let searchController = SearchProductViewController()
    searchController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: searchController, action: #selector(searchController.backButtonPressed))
    let navigationController = UINavigationController.init(rootViewController: searchController)
        self.present(navigationController, animated: true)
  }
}
  

extension PopUpViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let productImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      
    } else {
      
      print("No image was found")
    }
    
    dismiss(animated: true, completion: nil)
  }
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    
    dismiss(animated: true, completion: nil)
  }
}


