//
//  PhotoPicker.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 2/24/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import SwiftUI
import PhotosUI
import Combine

struct PhotoPicker: UIViewControllerRepresentable {
   
    @Binding var isPresented: Bool
    
    @ObservedObject var viewModel: ViewModel
    
    var chosenImagePassThroughSubject = PassthroughSubject<UIImage, AppError>()
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        let configuration: PHPickerConfiguration = .init()
        
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        
        private let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self]  image, _ in
                    DispatchQueue.main.async {
                        guard let self = self else {
                            return
                        }
                        if let image = image as? UIImage {
                            self.parent.viewModel.image = image
                        } else {
                            self.parent.chosenImagePassThroughSubject.send(completion: .failure(.imageNotFound))
                        }
                    }
                }
            }
            parent.isPresented = false
        }
    }
}
