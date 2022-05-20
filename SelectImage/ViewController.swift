//
//  ViewController.swift
//  SelectImage
//
//  Created by Vũ Việt Thắng on 13/05/2022.
//

import UIKit
import Photos

class ViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var imageCollection: UICollectionView!
    
    @IBOutlet weak var imageSelectionView: UIView!
    @IBOutlet weak var informLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var selectedImageCollection: UICollectionView!
    
    private var isSelected = false
    private var selectedArray = [Int]()
    private var selectedImageCellSize: Int?
    private var images = [PHAsset]()
    
    @IBAction func goBack(_ sender: UIButton){
        isSelected = false
        for value in selectedArray{
            let indexPath = IndexPath(row: value, section: 0)
            let cell = imageCollection.cellForItem(at: indexPath) as! CollectionViewCell
            cell.highlightView.alpha = 0
            cell.isChosen = false
        }
        selectedArray.removeAll()
        self.imageSelectionView.isHidden = true
        self.backButton.isHidden = true
        updateSelectOrder()
    }
    
    private func updateSelectOrder(){
        var order = 1
        for value in selectedArray{
            let indexPath = IndexPath(row: value, section: 0)
            let cell = imageCollection.cellForItem(at: indexPath) as! CollectionViewCell
            cell.pickOrderLabel.text = "\(order)"
            order += 1
        }
    }
    
    private func getImage(){
        PHPhotoLibrary.requestAuthorization{ status in
            if status == .authorized {
                let imageAssets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
                imageAssets.enumerateObjects{ (object, _, _) in
                    self.images.append(object)
                }
                let videoAssets = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: nil)
                videoAssets.enumerateObjects{ (object, _, _) in
                    self.images.append(object)
                }
                DispatchQueue.main.async {
                    self.imageCollection.reloadData()
                }
            }
        }
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer){
        switch gesture.state{
        case .began:
            guard let targetIndexPath = selectedImageCollection.indexPathForItem(at: gesture.location(in: selectedImageCollection)) else {
                return
            }
            selectedImageCollection.beginInteractiveMovementForItem(at: targetIndexPath)
        case .changed:
            selectedImageCollection.updateInteractiveMovementTargetPosition(gesture.location(in: selectedImageCollection))
        case .ended:
            selectedImageCollection.endInteractiveMovement()
            updateSelectOrder()
        default:
            selectedImageCollection.cancelInteractiveMovement()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollection.delegate = self
        imageCollection.dataSource = self
        self.imageCollection.register(UINib(nibName: "CollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CollectionViewCell")
        
        selectedImageCollection.delegate = self
        selectedImageCollection.dataSource = self
        self.selectedImageCollection.register(UINib(nibName: "SelectedImageCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SelectedImageCollectionViewCell")
        
        // make button edges round
        addButton.layer.cornerRadius = addButton.bounds.height / 2
        
        // get image from photo library
        getImage()
        
        // allow reorder by longpressing the selected image
        let gesture = UILongPressGestureRecognizer(target: self, action:#selector(handleLongPressGesture(_:)))
        selectedImageCollection.addGestureRecognizer(gesture)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.imageCollection{
            return images.count
        }
        else{
            return selectedArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.imageCollection{
            let noOfCellInRow = 4
            
            let size = (imageCollection.bounds.width - CGFloat(noOfCellInRow + 1)) / CGFloat(noOfCellInRow)
            
            return CGSize(width: size, height: size)
        }
        else{
            let size = collectionView.bounds.height
            return CGSize(width: size, height: size)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.imageCollection{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
            let index = selectedArray.firstIndex(of: indexPath.row)
            cell.createCell(index: index ?? 0, assets: images[indexPath.row])
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedImageCollectionViewCell", for: indexPath) as! SelectedImageCollectionViewCell
            cell.delegate = self
            
            //get the selected image
            let imageIndexPath = IndexPath(row: selectedArray[indexPath.row], section: 0)
            let imageCell = imageCollection.cellForItem(at: imageIndexPath) as! CollectionViewCell
            let image = imageCell.imageView.image
            cell.selectedIndex = selectedArray[indexPath.row]
            cell.createCell(image: image!)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.imageCollection{
            let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
            if cell.isChosen{
                cell.isChosen = false
                cell.highlightView.alpha = 0
                let index = selectedArray.firstIndex(of: indexPath.row)
                selectedArray.remove(at: index!)
                if selectedArray.count == 0{
                    isSelected = false
                    self.imageSelectionView.isHidden = true
                    self.backButton.isHidden = true
                }
                updateSelectOrder()
            }
            else{
                cell.isChosen = true
                if isSelected == false{
                    isSelected = true
                    self.imageSelectionView.isHidden = false
                    self.backButton.isHidden = false
                    selectedArray.append(indexPath.row)
                }
                else{
                    selectedArray.append(indexPath.row)
                }
                cell.highlightView.alpha = 0.5
                updateSelectOrder()
            }
            self.selectedImageCollection.reloadData()
        }
        else{
            //no function when tap the selected images
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = selectedArray.remove(at: sourceIndexPath.row)
        selectedArray.insert(item, at: destinationIndexPath.row)
    }
}

// MARK: - SelectedImageCollectionViewCellDelegate
extension ViewController: SelectedImageCollectionViewCellDelegate{
    func selectedImageCollectionViewCell(_ cell: SelectedImageCollectionViewCell, didTapDeleteButtonWithIndex index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        let cell = self.imageCollection.cellForItem(at: indexPath) as! CollectionViewCell
        cell.isChosen = false
        cell.highlightView.alpha = 0
        let deletedIndex = selectedArray.firstIndex(of: indexPath.row)
        selectedArray.remove(at: deletedIndex!)
        if selectedArray.count == 0{
            isSelected = false
            self.imageSelectionView.isHidden = true
            self.backButton.isHidden = true
        }
        updateSelectOrder()
        self.selectedImageCollection.reloadData()
    }
}
