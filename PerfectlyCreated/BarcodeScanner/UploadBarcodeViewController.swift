//
//  UploadBarcodeViewController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 1/13/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import UIKit
import Combine

final class UploadBarcodeViewController: UIViewController {
    
    @IBOutlet private weak var chosenImageImageView: UIImageView!
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var backBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var cropView: UIView!
    @IBOutlet private weak var toastLabel: UILabel!
    
    private lazy var barcodeController = BarCodeScannerController()
    
    var bacodeStringPublisher: AnyPublisher<String, Never> {
        return bacodeStringSubject.eraseToAnyPublisher()
    }
    
    private var bacodeStringSubject = PassthroughSubject<String, Never>()
    
    private let chosenImage: UIImage
    
    private var cancellables = Set<AnyCancellable>()
    
    init?(coder: NSCoder, chosenImage: UIImage) {
        self.chosenImage = chosenImage
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backBarButtonItem.tintColor = .white
        saveBarButtonItem.tintColor = .white
        chosenImageImageView.image = chosenImage
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 2
        
        cropView.borderWidth = 3.0
        cropView.borderColor = .black
        
        navigationController?.configuresShadowlessTransparentNavigationBar(backgroundColor: .black)
        saveBarButtonItem.tapPublisher.sink { [weak self] _ in
            guard let self = self else {
                return
            }
            self.barcodeController.captureOutout(with: self.chosenImage) { result in
                switch result {
                    case let .failure(error):
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    case let .success(barcodeString):
                        self.bacodeStringSubject.send(barcodeString)
                        self.navigationController?.popViewController(animated: true)
                }
            }
        }
        .store(in: &cancellables)
        
        backBarButtonItem.tapPublisher.sink { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        .store(in: &cancellables)
    }
}

extension UploadBarcodeViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return chosenImageImageView
    }
}
