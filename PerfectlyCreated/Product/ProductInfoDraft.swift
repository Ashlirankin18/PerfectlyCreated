//
//  ProductInfoDraft.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 1/13/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import Foundation
import Combine

/// Objects which contains the intermediate state of editing product experience.
final class ProductInfoDraft {
    
    /// The product document id.
    var documentId: String = ""
    
    /// Publisher of the the notes property.
    @Published var notes = ""
    
    /// Publisher of the the isComplete property.
    @Published var isCompleted = false
}
