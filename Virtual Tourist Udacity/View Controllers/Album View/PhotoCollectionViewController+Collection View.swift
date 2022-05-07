//
//  PhotoCollectionViewController+Collection View.swift
//  Virtual Tourist Udacity
//
//  Created by Min Kaung Htet on 06/05/2022.
//

import Foundation
import UIKit

extension PhotoCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        return count
    }

      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

       // CollectionView
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewCell.reuseIdentifier, for: indexPath as IndexPath) as! PhotoViewCell
        guard !(self.fetchedResultsController.fetchedObjects?.isEmpty)! else {
            print("images are already present.")
            return cell
        }
    
        // fetch core data
        let photoData = self.fetchedResultsController.object(at: indexPath)

        
        if photoData.imageData == nil {

            newCollectionButton.isEnabled = false
            DispatchQueue.global(qos: .background).async {
                if let imageData = try? Data(contentsOf: photoData.imageUrl!) {
                    DispatchQueue.main.async {
                        photoData.imageData = imageData
                        do {
                            try self.dataController.viewContext.save()
                            
                        } catch {
                            print("error in saving image data")
                        }
                        
                        let image = UIImage(data: imageData)!
                        cell.setPhotoImageView(imageView: image, sizeFit: true)
         
                    }
                }
        
            }
            
        } else {
          if let imageData = photoData.imageData {
                let image = UIImage(data: imageData)!
                cell.setPhotoImageView(imageView: image, sizeFit: false)
            }
            
        }
        newCollectionButton.isEnabled = true
        return cell
    }

    // Set up the Collection View.
    func setUpCollectionView() {
        // Set up Collection View
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        configureFlowLayout()
    }

    // Set up the flow layout for the Collection View.
    func configureFlowLayout() {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
         let space: CGFloat = 3.0
         let dimension = (view.frame.size.width - (2 * space)) / 3.0
         flowLayout.minimumInteritemSpacing = space
         flowLayout.minimumLineSpacing = space
         flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        }
    }
}
