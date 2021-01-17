//
//  ProductCollectionViewCell.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 10/31/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit

/// `UICollectionViewCell` subclass which displays the user's chosen product.
final class ProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
 
    override func layoutSubviews() {
        super.layoutSubviews()
        configureCell()
    }
    
    private func configureCell() {
          layer.cornerRadius = frame.height / 2
          layer.masksToBounds = false
          contentView.layer.cornerRadius = 25
          contentView.layer.masksToBounds = true
          layer.shadowColor = UIColor.appPurple.withAlphaComponent(0.3).cgColor
          layer.shadowOffset = CGSize(width: 0, height: 2)
          layer.shadowOpacity = 1.0
          
          self.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
      }
}
