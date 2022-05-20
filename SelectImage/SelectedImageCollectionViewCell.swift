//
//  SelectedImageCollectionViewCell.swift
//  SelectImage
//
//  Created by Vũ Việt Thắng on 19/05/2022.
//

import UIKit

class SelectedImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var delegate: SelectedImageCollectionViewCellDelegate?
    var selectedIndex: Int!
    
    @IBAction func deleteSelectedImage(_ sender: UIButton){
        delegate?.selectedImageCollectionViewCell(self, didTapDeleteButtonWithIndex: selectedIndex)
    }
    
    func createCell(image: UIImage){
        self.imageView.image = image
    }
}

protocol SelectedImageCollectionViewCellDelegate{
    func selectedImageCollectionViewCell(_ cell: SelectedImageCollectionViewCell, didTapDeleteButtonWithIndex index: Int)
}
