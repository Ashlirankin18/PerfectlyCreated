//
//  ViewModel.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 3/13/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

final class ViewModel: ObservableObject {
    
    @Published var image: UIImage?
    
    var productName: String = ""
    
    var productDescription: String = ""
    
    var barcodeString: String = ""
    
    var cameraModel: CameraModel = CameraModel()

    private lazy var storageManager = StorageManager()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        getPhoto()
    }
    
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
    
    func getPhoto() {
        cameraModel.$photo.sink { photo in
            if let photo = photo {
                self.image = photo.image
            } else {
                self.image = nil
            }
        }
        .store(in: &cancellables)
    }
}
