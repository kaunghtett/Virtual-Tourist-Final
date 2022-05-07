//
//  PhotoViewCell.swift
//  Virtual Tourist Udacity
//
//  Created by Min Kaung Htet on 06/05/2022.
//

import UIKit
import CoreData

class PhotoViewCell: UICollectionViewCell {
    
   
    @IBOutlet weak var photoImageView: UIImageView!

    static let reuseIdentifier = "PhotoViewCell"
    

    func setPhotoImageView(imageView: UIImage, sizeFit: Bool) {
        photoImageView.image = imageView
        if sizeFit == true {
            photoImageView.sizeToFit()
        }
    }
}
