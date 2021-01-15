//
//  VideoSessionController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 10/31/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Combine

/// Controls the logic related to reading the barcodes.
final class VideoSessionController: NSObject {
    
    private lazy var session: AVCaptureSession = AVCaptureSession()
    
    private var aVCaptureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let backgroundView: UIView
    
    private lazy var barcodeController = BarCodeScannerController()
    
    /// Subscriber to this publisher to recieve chages related to the barcode.
    var bacodeStringPublisher: AnyPublisher<String, Error> {
        return bacodeStringSubject.eraseToAnyPublisher()
    }
    
    private var bacodeStringSubject = PassthroughSubject<String, Error>()
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Creates a new instance of `VideoSessionController`.
    /// - Parameter backgroundView: The view which will display the video.
    init(backgroundView: UIView) {
        self.backgroundView = backgroundView
    }
    
    private func startRunningSession() {
        session.startRunning()
    }
    
    private func stopRunningSession() {
        session.stopRunning()
    }
    
    /// Configures the AvCaptureDevice.
    func configureCaptureDevice() {
        startRunningSession()
        
        session.sessionPreset = AVCaptureSession.Preset.iFrame1280x720
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: .global())
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        configureOutput()
        
        session.startRunning()
        
    }

    private func configureOutput() {
        aVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        aVCaptureVideoPreviewLayer?.frame = backgroundView.bounds
        aVCaptureVideoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        if let previewLayerUnwrap = aVCaptureVideoPreviewLayer {
            backgroundView.layer.addSublayer(previewLayerUnwrap)
        }
    }
}

extension VideoSessionController: AVCaptureVideoDataOutputSampleBufferDelegate {
     
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        barcodeController.captureOutput(output, didOutput: sampleBuffer, from: connection) { [weak self] result in
            
            guard let self = self else {
                return
            }
            switch result {
                case let .failure(error):
                    self.bacodeStringSubject.send(completion: .failure(error))
                case let .success(barcodeString):
                    self.bacodeStringSubject.send(barcodeString)
            }
        }
    }
}
