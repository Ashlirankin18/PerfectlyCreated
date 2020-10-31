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

final class BarCodeScannerController {
    
    private lazy var barcodeDetector: BarcodeScanner = {
        let scanner = BarcodeScanner.barcodeScanner()
        return scanner
    }()
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let visionImage = VisionImage(buffer: sampleBuffer)
        
        barcodeDetector.process(visionImage) { barcodes, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let barcodes = barcodes {
                for barcode in barcodes {
                    print(barcode.rawValue!)
                }
            }
        }
    }
}
