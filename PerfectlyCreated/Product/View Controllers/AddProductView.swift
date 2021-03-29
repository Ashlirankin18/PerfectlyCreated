//
//  AddProductView.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 2/24/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import SwiftUI
import Combine
import PhotosUI
import Camera_SwiftUI
import AVFoundation

struct AddProductView: View {
    
    @State private var isPresented: Bool = false
    
    @ObservedObject var viewModel: ViewModel
    
    @ObservedObject var cameraModel = CameraModel() {
        didSet {
            viewModel.cameraModel = cameraModel
        }
    }
    
    var backButtonTapped: (() -> Void)?
    
    var saveButtonTapped: (() -> Void)?
    
    var body: some View {
        NavigationView {
            VStack {
                Form(content: {
                    Section(footer:
                                Text("This product has no description").foregroundColor(.secondary).bold()) {
                        HStack {
                            Text("Barcode Number: ")
                            Spacer()
                            Text(viewModel.barcodeString)
                        }
                        
                        TextField("Enter Product Name", text: $viewModel.productName)
                    }
                    Section(header: Text("Add an image to the product."), footer:
                                Text("Adding this product helps our community greatly")
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                    ) {
                        Button(action: {
                            isPresented.toggle()
                        }, label: {
                            Text("Take a photo")
                        })
                        .sheet(isPresented: $isPresented, content: {
                            GeometryReader { geo in
                                CameraView(isPresented: $isPresented, model: cameraModel)
                                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                            }
                        })
                        Button(action: {
                            isPresented.toggle()
                        }, label: {
                            Text("Upload a photo")
                        })
                        .sheet(isPresented: $isPresented, content: {
                            PhotoPicker(isPresented: $isPresented, viewModel: viewModel)
                        })
                        HStack {
                            Spacer()
                            Image(uiImage: (viewModel.retrieveImage()))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300, height: 300, alignment: .center)
                            Spacer()
                        }
                    }
                })
            }
            .navigationBarItems(leading:
                                    Button(action: {
                                        backButtonTapped?()
                                    }, label: {
                                        Image(systemName: "multiply")
                                    })
                                    .foregroundColor(Color(UIColor.appPurple)), trailing:
                                        Button(action: {
                                            saveButtonTapped?()
                                        }, label: {
                                            Text("Save")
                                        })
                                        .foregroundColor(Color(UIColor.appPurple)))
            
            .navigationTitle(Text("Add Product"))
        }
    }
}

final class CameraModel: ObservableObject {
    private let service = CameraService()
    
    @Published var photo: Photo!
    
    @Published var showAlertError = false
    
    @Published var isFlashOn = false
    
    @Published var willCapturePhoto = false
    
    var alertError: AlertError!
    
    var session: AVCaptureSession
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        self.session = service.session
        
        service.$photo.sink { [weak self] (photo) in
            guard let pic = photo else {
                return
            }
            self?.photo = pic
        }
        .store(in: &self.subscriptions)
        
        service.$shouldShowAlertView.sink { [weak self] (val) in
            self?.alertError = self?.service.alertError
            self?.showAlertError = val
        }
        .store(in: &self.subscriptions)
        
        service.$flashMode.sink { [weak self] (mode) in
            self?.isFlashOn = mode == .on
        }
        .store(in: &self.subscriptions)
        
        service.$willCapturePhoto.sink { [weak self] (val) in
            self?.willCapturePhoto = val
        }
        .store(in: &self.subscriptions)
    }
    
    func configure() {
        service.checkForPermissions()
        service.configure()
    }
    
    func capturePhoto() {
        service.capturePhoto()
    }
    
    func flipCamera() {
        service.changeCamera()
    }
    
    func zoom(with factor: CGFloat) {
        service.set(zoom: factor)
    }
    
    func switchFlash() {
        service.flashMode = service.flashMode == .on ? .off : .on
    }
}

struct CameraView: View {
    
    @State var isPresented: Binding<Bool>
    
    @ObservedObject var model: CameraModel
    
    @State var currentZoomFactor: CGFloat = 1.0
    
    var imageCapturedHandler: (() -> Void)?
    
    var captureButton: some View {
        Button(action: {
            model.capturePhoto()
            isPresented.wrappedValue.toggle()
        }, label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 80, height: 80, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 65, height: 65, alignment: .center)
                )
        })
    }
    
    var capturedPhotoThumbnail: some View {
        Group {
            if model.photo != nil {
                Image(uiImage: model.photo.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .animation(.spring())
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60, alignment: .center)
                    .foregroundColor(.black)
            }
        }
    }
    
    var flipCameraButton: some View {
        Button(action: {
            model.flipCamera()
        }, label: {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .foregroundColor(.white))
        })
    }
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Button(action: {
                        model.switchFlash()
                    }, label: {
                        Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 20, weight: .medium, design: .default))
                    })
                    .accentColor(model.isFlashOn ? .yellow : .white)
                    
                    CameraPreview(session: model.session)
                        .gesture(
                            DragGesture().onChanged({ (val) in
                                //  Only accept vertical drag
                                if abs(val.translation.height) > abs(val.translation.width) {
                                    //  Get the percentage of vertical screen space covered by drag
                                    let percentage: CGFloat = -(val.translation.height / reader.size.height)
                                    //  Calculate new zoom factor
                                    let calc = currentZoomFactor + percentage
                                    //  Limit zoom factor to a maximum of 5x and a minimum of 1x
                                    let zoomFactor: CGFloat = min(max(calc, 1), 5)
                                    //  Store the newly calculated zoom factor
                                    currentZoomFactor = zoomFactor
                                    //  Sets the zoom factor to the capture device session
                                    model.zoom(with: zoomFactor)
                                }
                            })
                        )
                        .onAppear {
                            model.configure()
                        }
                        .alert(isPresented: $model.showAlertError, content: {
                            Alert(title: Text(model.alertError.title), message: Text(model.alertError.message), dismissButton: .default(Text(model.alertError.primaryButtonTitle), action: {
                                model.alertError.primaryAction?()
                            }))
                        })
                        .overlay(
                            Group {
                                if model.willCapturePhoto {
                                    Color.black
                                }
                            }
                        )
                        .animation(.easeInOut)
                    HStack {
                        capturedPhotoThumbnail
                        
                        Spacer()
                        
                        captureButton
                        
                        Spacer()
                        
                        flipCameraButton
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}
