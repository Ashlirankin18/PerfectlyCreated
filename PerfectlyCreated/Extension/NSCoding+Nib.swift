//
//  NSCoding+Nib.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 11/1/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import Foundation

extension NSCoding {
    
    /// The default name for a nib. Matches the name of the class, without any module name spacing.
    static var defaultNibName: String {
        return String(describing: self)
    }
}
