//
//  CollectionViewCell.swift
//  SelectImage
//
//  Created by Vũ Việt Thắng on 13/05/2022.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var highlightView: UIView!
    @IBOutlet weak var pickOrderLabel: UILabel!

    var isChosen = false
    var cellSize: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        let gradient = CAGradientLayer()

        gradient.frame = view.frame

        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]

        gradient.locations = [0.65, 1.0]

        view.layer.insertSublayer(gradient, at: 0)

        imageView.addSubview(view)

        imageView.bringSubviewToFront(view)
    }
    func createCell(index: Int) {
        
        let images = [
            UIImage(named: "angry"),
            UIImage(named: "confused"),
            UIImage(named: "happy"),
            UIImage(named: "sad"),
            UIImage(named: "meh"),
            UIImage(named: "crying"),
            UIImage(named: "sleepy"),
            UIImage(named: "goofy")
        ].compactMap({$0})
        self.imageView.image = images.randomElement()
        self.pickOrderLabel.text = "\(index)"
    }
}
