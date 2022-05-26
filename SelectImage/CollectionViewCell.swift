//
//  CollectionViewCell.swift
//  SelectImage
//
//  Created by Vũ Việt Thắng on 13/05/2022.
//

import UIKit
import Photos

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var highlightView: UIView!
    @IBOutlet private weak var pickOrderLabel: UILabel!

    private var isChosen = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //create gradient layer
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let gradient = CAGradientLayer()
        gradient.frame = view.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.65, 1.0]
        view.layer.insertSublayer(gradient, at: 0)
        imageView.addSubview(view)
        imageView.bringSubviewToFront(view)
    }
    
    func createCell(index: Int, asset: PHAsset) {
        // get image or video's thumbnail
        let manager = PHImageManager.default()
        manager.requestImage(for: asset, targetSize: CGSize(width: self.bounds.width, height: self.bounds.height), contentMode: .aspectFill, options: nil){ image, _ in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        setVideoTimeLabel(asset: asset)
        // set image's pick order
        self.pickOrderLabel.text = "\(index)"
    }
    
    func changeChosenCell(){
        isChosen = !isChosen
        highlightView.alpha = isChosen ? 0.5 : 0
    }
    
    func setVideoTimeLabel(asset: PHAsset){
        // get video's duration
        if asset.duration != 0{
            let minutes = Int(asset.duration / 60)
            let seconds = Int(asset.duration.truncatingRemainder(dividingBy: 60))
            var minutesLabel = String(minutes)
            var secondsLabel = String(seconds)
            if minutes < 10{
                minutesLabel = "0" + minutesLabel
            }
            if seconds < 10{
                secondsLabel = "0" + secondsLabel
            }
            self.timeLabel.text =  minutesLabel + ":" + secondsLabel
        }
    }
    
    func setPickOrderLabel(order: Int){
        self.pickOrderLabel.text = "\(order)"
    }
}

