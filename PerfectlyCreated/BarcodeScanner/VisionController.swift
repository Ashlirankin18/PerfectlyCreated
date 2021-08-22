//
//  VisionController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 8/22/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import Foundation
import Vision
import UIKit

final class VisionController {
    
    var visionBarCodeDetectionRequest : VNDetectBarcodesRequest {
        let request = VNDetectBarcodesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                return
            }
            else {
                guard let observations = request.results as? [VNDetectedObjectObservation] else {
                    return
                }
                print("Observations are \(observations)")
            }
        }
        return request
    }
    
    func createVisionRequest(image: UIImage) {
        guard let cgImage = image.cgImage else {
            return
        }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImageOrientation, options: [:])
        let visionRequest = [visionBarCodeDetectionRequest]
        DispatchQueue.global(qos: .background).async {
            do {
                try requestHandler.perform(visionRequest)
            } catch let error as NSError {
                print("Error in performing Image request: \(error)")
            }
        }
    }
}

private extension UIImage {
    
    var cgImageOrientation : CGImagePropertyOrientation {
        switch imageOrientation {
            case .up: return .up
            case .upMirrored: return .upMirrored
            case .down: return .down
            case .downMirrored: return .downMirrored
            case .leftMirrored: return .leftMirrored
            case .right: return .right
            case .rightMirrored: return .rightMirrored
            case .left: return .left
            default: return .up
        }
    }
}
