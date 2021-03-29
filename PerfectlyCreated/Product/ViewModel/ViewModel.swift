//
//  ViewModel.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 3/13/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import UIKit
import SwiftUI

final class ViewModel: ObservableObject {
    
    @Published var image: UIImage?
    
    var productName: String = ""
    
    var productDescription: String = ""
    
    var barcodeString: String = ""
    
    var cameraModel: CameraModel? {
        didSet {
            self.image = cameraModel?.photo.image
        }
    }
    
    private lazy var storageManager = StorageManager()
    
    func retrieveImage() -> UIImage {
        return image ?? UIImage()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func snapshotURL() -> URL? {
        if let data = self.retrieveImage().pngData() {
            let filename = getDocumentsDirectory().appendingPathComponent("PerfectlyCreated.png")
            do {
                try data.write(to: filename)
            } catch {
                print(error)
            }
            return filename
        } else {
            return nil
        }
    }
    
    func saveImage() -> URL? {
        guard let data = retrieveImage().pngData() else {
            return nil
        }
        storageManager.postImage(withData: data)
        return snapshotURL()
    }
}
