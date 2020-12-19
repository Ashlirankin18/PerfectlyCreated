//
//  UINavigationBar+Appearance.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 12/12/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    /// Sets the standard appearance for the navigation bar with an opaque shadowless background and optionality for font + color.
    /// - Parameters:
    ///   - font: The font to be applied to the navigation bar, defaults to `title3`.
    ///   - color: The color to be applied to the navigation bar, defaults to `grey100`.
    ///   - backgroundColor: The navigationBar's background color
    func configuresShadowlessOpaqueNavigationBar(withFont font: UIFont = .systemFont(ofSize: 17), withColor color: UIColor = UIColor.black, backgroundColor: UIColor = UIColor.white) {
        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: font
        ]
        let standardAppearance = navigationBar.standardAppearance
        standardAppearance.titleTextAttributes = titleTextAttributes
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.shadowColor = .clear
        standardAppearance.backgroundColor = backgroundColor
        self.navigationBar.standardAppearance = standardAppearance
    }
    
    /// Sets the standard appearance for the navigation bar with an transparent shadowless background and optionality for font + color.
    /// - Parameters:
    ///   - font: The font to be applied to the navigation bar, defaults to `title3`.
    ///   - color: The color to be applied to the navigation bar, defaults to `grey100`.
    ///   - backgroundColor: he navigationBar's background color
    func configuresShadowlessTransparentNavigationBar(withFont font: UIFont = .systemFont(ofSize: 17), withColor color: UIColor = UIColor.black, backgroundColor: UIColor = UIColor.white) {
        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: font
        ]
        let standardAppearance = navigationBar.standardAppearance
        standardAppearance.titleTextAttributes = titleTextAttributes
        standardAppearance.configureWithTransparentBackground()
        standardAppearance.shadowColor = .clear
        standardAppearance.backgroundColor = backgroundColor
        self.navigationBar.standardAppearance = standardAppearance
    }
}
