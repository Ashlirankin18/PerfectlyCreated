//
//  NSCoding+Nib.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 11/1/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import Foundation

extension NSCoding {
    
    /// The name for a nib.
    static var nibName: String {
        return String(describing: self)
    }
}
