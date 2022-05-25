//
//  SelectedImageCollectionViewCell.swift
//  SelectImage
//
//  Created by Vũ Việt Thắng on 19/05/2022.
//

import UIKit
import Photos

class SelectedImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    
    weak var delegate: SelectedImageCollectionViewCellDelegate?
    var index: Int!
    
    @IBAction func deleteSelectedImage(_ sender: UIButton){
        delegate?.selectedImageCollectionViewCell(self, didTapDeleteButtonWithIndex: index)
    }
    
    func createCell(asset: PHAsset){
        // get image or video's thumbnail
        let manager = PHImageManager.default()
        manager.requestImage(for: asset, targetSize: CGSize(width: self.bounds.width, height: self.bounds.height), contentMode: .aspectFill, options: nil){ image, _ in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
}

protocol SelectedImageCollectionViewCellDelegate: AnyObject{
    func selectedImageCollectionViewCell(_ cell: SelectedImageCollectionViewCell, didTapDeleteButtonWithIndex index: Int)
}
