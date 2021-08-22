//
//  StorageManager.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 3/29/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseAuth
import UIKit

class StorageManager {
    
    private lazy var storage: Storage = {
        return Storage.storage()
    }()
    
    private lazy var storageRef: StorageReference = {
        return Storage.storage().reference()
    }()
    
    func retrieveItemImages(imageURL: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        storage.reference(forURL: imageURL).getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let data = data {
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        completion(.success(image))
                    }
                }
            }
        }
    }
    
    func postImage(withData data: Data, urlHandler: @escaping ((URL) -> Void)) {
        guard let user = Auth.auth().currentUser else {
            print("no logged user")
            return
        }
        let imagesRef = storageRef.child("images")
        let newImageRef = imagesRef.child("\(user.uid).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let uploadTask = newImageRef.putData(data, metadata: metadata) { (metadata, error) in
            guard metadata != nil else {
                print("error uploading data")
                return
            }
            newImageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    print("downloadURL error: \(error)")
                } else if let url = url {
                    urlHandler(url)
                }
            })
        }
        // observe states on uploadTask
        uploadTask.observe(.failure) { _ in
            print("failure...")
        }
        uploadTask.observe(.pause) { _ in
            print("pause...")
        }
        uploadTask.observe(.progress) { _ in
            print("progress...")
        }
        uploadTask.observe(.resume) { _ in
            print("resume...")
        }
        uploadTask.observe(.success) { _ in
            print("success...")
        }
    }
}
