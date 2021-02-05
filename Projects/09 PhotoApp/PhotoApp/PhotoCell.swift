//
//  PhotoCell.swift
//  PhotoApp
//
//  Created by Stanly Shiyanovskiy on 31.12.2020.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell {
    var imageView = UIImageView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView.superview == nil {
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            contentView.addSubview(imageView)
        }
        
        imageView.frame = bounds
    }
}
