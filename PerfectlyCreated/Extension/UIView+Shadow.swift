//
//  UIView+Shadow.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 2/3/21.
//  Copyright © 2021 Ashli Rankin. All rights reserved.
//

import Foundation
import UIKit

enum VerticalLocation: String {
    case bottom
    case top
    case all
}

extension UIView {
    func addShadow(location: VerticalLocation, color: UIColor = UIColor.appPurple.withAlphaComponent(0.3), opacity: Float = 0.5, radius: CGFloat = 3.0) {
        switch location {
        case .bottom:
                addShadow(offset: CGSize(width: 0, height: 10), color: color, opacity: opacity, radius: radius)
        case .top:
                addShadow(offset: CGSize(width: 0, height: -10), color: color, opacity: opacity, radius: radius)
        case .all:
                addShadow(offset: CGSize(width: 0, height: -2), color: color, opacity: opacity, radius: 12.0)
        }
    }
    
    func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
}
