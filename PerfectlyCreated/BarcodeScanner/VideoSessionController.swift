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
class VideoSessionController: NSObject {
    
    private lazy var session: AVCaptureSession = AVCaptureSession()
    
    private var aVCaptureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private var barcodeController = BarCodeScannerController()
    
    /// Subscriber to this publisher to receive changes related to the barcode.
    var barcodeStringPublisher: AnyPublisher<String, Error> {
        return barcodeStringSubject.eraseToAnyPublisher()
    }
    
    private var barcodeStringSubject = PassthroughSubject<String, Error>()
    
    private var cancellables = Set<AnyCancellable>()
    
    func startRunningSession() {
        session.startRunning()
    }
    
    func stopRunningSession() {
        session.stopRunning()
    }
    
    /// Configures the AvCaptureDevice.
    func configureCaptureDevice(with view: UIView) {
        startRunningSession()
        
        session.sessionPreset = AVCaptureSession.Preset.iFrame1280x720
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video), let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: .global())
        
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        configureOutput(view: view)
        
        session.startRunning()
    }
    
    private func configureOutput(view: UIView) {
        aVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        aVCaptureVideoPreviewLayer?.frame = view.bounds
        aVCaptureVideoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        if let previewLayerUnwrap = aVCaptureVideoPreviewLayer {
            view.layer.addSublayer(previewLayerUnwrap)
        }
    }
}

extension VideoSessionController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        barcodeController.captureOutput(with: .buffer(buffer: sampleBuffer))
            .removeDuplicates()
            .first { !$0.isEmpty }
            .sink(result: { result in
                switch result {
                case let .failure(error):
                    print("There is an error: \(error.localizedDescription)")
                case let .success(barcodeString):
                    self.barcodeStringSubject.send(barcodeString)
                }
            })
            .store(in: &self.cancellables)
    }
}
