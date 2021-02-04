//
//  BarcodeScannerController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 10/31/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import Foundation
import MLKitBarcodeScanning
import UIKit
import AVFoundation
import MLKitVision
import Combine

/// Handles the barcode processing logic.
final class BarCodeScannerController {
    
    /// Represents the output types.
    enum OutputType {
        
        case image(image: UIImage)
        
        case buffer(buffer: CMSampleBuffer)
    }
    
    private lazy var barcodeDetector: BarcodeScanner = {
        let scanner = BarcodeScanner.barcodeScanner()
        return scanner
    }()
    
    private let passThroughSubject = PassthroughSubject<String, AppError>()
    
    /// Captures the output.
    /// - Parameter outputType: The type of out put we received.
    /// - Returns: Publisher of the barcode string received. Or a possible error.
    func captureOutput(with outputType: OutputType) -> AnyPublisher<String, AppError> {
        
        let visionImage: VisionImage
        
        switch outputType {
        case let .buffer(buffer):
            visionImage = VisionImage(buffer: buffer)
        case let .image(image):
            visionImage = VisionImage(image: image)
        }
       
        barcodeDetector.process(visionImage) { [weak self] barcodes, error in
            if let error = error {
                self?.passThroughSubject.send(completion: .failure(.processingError(error)))
            }
            
            if let barcodes = barcodes {
                
                for barcode in barcodes {
                    if let barCodeString = barcode.rawValue {
                        self?.passThroughSubject.send(barCodeString)
                    } else {
                        self?.passThroughSubject.send(completion: .failure(.noBarcodeFound))
                    }
                }
                
                switch outputType {
                case .buffer: break
                case .image:
                    if barcodes.isEmpty {
                        self?.passThroughSubject.send(completion: .failure(.noBarcodeFound))
                    }
                }
            } else {
                self?.passThroughSubject.send(completion: .failure(.noBarcodeFound))
            }
        }
        return passThroughSubject.eraseToAnyPublisher()
    }
}
