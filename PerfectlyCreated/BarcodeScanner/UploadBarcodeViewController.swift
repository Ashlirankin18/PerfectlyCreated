//
//  UploadBarcodeViewController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 1/13/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import UIKit
import Combine

/// `UIViewController` subclass which allows the user to upload a bar code.
final class UploadBarcodeViewController: UIViewController {
    
    @IBOutlet private weak var chosenImageImageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var backBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var cropView: UIView!
    @IBOutlet private weak var toastLabel: UILabel!
    
    private lazy var barcodeController = BarCodeScannerController()
    
    /// Publisher which sends barcode changes.
    var barcodeStringPublisher: AnyPublisher<String, Never> {
        return bacodeStringSubject.eraseToAnyPublisher()
    }
    
    private var bacodeStringSubject = PassthroughSubject<String, Never>()
    
    private let chosenImage: UIImage
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Creates a new instance of `UploadBarcodeViewController`.
    /// - Parameters:
    ///   - coder: An abstract class that serves as the basis for objects that enable archiving and distribution of other objects.
    ///   - chosenImage: The chosen image.
    init?(coder: NSCoder, chosenImage: UIImage) {
        self.chosenImage = chosenImage
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBarButtonItems()
        configureScrollView()
        navigationController?.configuresShadowlessTransparentNavigationBar(backgroundColor: .black)
        configureSaveButton()
        configureBackButton()
    }
    
    // MARK: - UploadBarcodeViewController
    
    private func configureBarButtonItems() {
        backBarButtonItem.tintColor = .white
        saveBarButtonItem.tintColor = .white
    }
    
    private func configureScrollView() {
        chosenImageImageView.image = chosenImage
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 2
        
        cropView.borderWidth = 3.0
        cropView.borderColor = .black
    }
    
    private func configureSaveButton() {
        saveBarButtonItem.tapPublisher.sink { [weak self] _ in
            guard let self = self else {
                return
            }
            self.barcodeController.captureOutput(with: .image(image: self.chosenImage))
                .sink { [weak self] completion in
                    switch completion {
                    case let .failure(error):
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    case .finished: break
                    }
                } receiveValue: { [weak self] barcodeString in
                    self?.bacodeStringSubject.send(barcodeString)
                    self?.navigationController?.popViewController(animated: true)
                }
                .store(in: &self.cancellables)
        }
        .store(in: &cancellables)
    }
    
    private func configureBackButton() {
        backBarButtonItem.tapPublisher.sink { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        .store(in: &cancellables)
    }
}

extension UploadBarcodeViewController: UIScrollViewDelegate {
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return chosenImageImageView
    }
}
