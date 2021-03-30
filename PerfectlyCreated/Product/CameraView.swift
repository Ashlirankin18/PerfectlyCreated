//
//  CameraView.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 3/30/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import SwiftUI
import Camera_SwiftUI

struct CameraView: View {
    
    @State var isPresented: Binding<Bool>
    
    @State private var currentAmount: CGFloat = 0
    
    @State private var finalAmount: CGFloat = 1
    
    @StateObject var model = CameraModel()
    
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
                    .scaleEffect(finalAmount + currentAmount)
                    .gesture(
                        MagnificationGesture()
                            .onChanged({ amount in
                                currentAmount = amount - 0.5
                            })
                            .onEnded({ _ in
                                finalAmount += currentAmount
                                currentAmount = 0
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
