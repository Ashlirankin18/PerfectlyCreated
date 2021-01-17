//
//  BarcodeScannerViewController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 10/31/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit
import Combine

/// `UIViewController` subclass which displays the barcode scanner.
final class BarcodeScannerViewController: UIViewController {
    
    @IBOutlet private weak var barcodeView: UIView!
    
    private lazy var videoSession = VideoSessionController(backgroundView: barcodeView)
    
    private var cancelButton = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .done, target: nil, action: nil)
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Subscriber to this publisher to recieve chages related to the barcode.
    var barcodeStringPublisher: AnyPublisher<String, Error> {
        return bacodeStringSubject.eraseToAnyPublisher()
    }
    
    private var bacodeStringSubject = PassthroughSubject<String, Error>()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCancelButton()
        configureBarcodeScannerPublisher()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoSession.configureCaptureDevice()
    }
    
    // MARK: - BarcodeScannerViewController
    
    private func configureCancelButton() {
        cancelButton.tintColor = .white
        navigationItem.leftBarButtonItem = cancelButton
        navigationController?.configuresShadowlessTransparentNavigationBar(backgroundColor: .black)
        
        cancelButton.tapPublisher.sink { _ in
            self.dismiss(animated: true  )
        }
        .store(in: &cancellables)
    }
    
    private func configureBarcodeScannerPublisher() {
        videoSession.bacodeStringPublisher
            .removeDuplicates()
            .sink { [weak self] result in
                switch result {
                    case let .failure(error):
                        self?.dismiss(animated: true)
                        self?.bacodeStringSubject.send(completion: .failure(error))
                        
                    case .finished: break
                }
            } receiveValue: { [weak self] barcodeString in
                guard let self = self else {
                    return
                }
                self.dismiss(animated: true)
                self.bacodeStringSubject.send(barcodeString)
            }.store(in: &cancellables)
    }
}
