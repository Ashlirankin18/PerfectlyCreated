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

/// Controls the logic related to reading the barcodes.
final class VideoSessionController: NSObject {
    
    private lazy var session: AVCaptureSession = AVCaptureSession()
    
    private var aVCaptureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let backgroundView: UIView
    
    private lazy var barcodeController = BarCodeScannerController()
    
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
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        barcodeController.captureOutput(output, didOutput: sampleBuffer, from: connection)
    }
}
