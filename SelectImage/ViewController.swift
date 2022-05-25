//
//  ViewController.swift
//  SelectImage
//
//  Created by Vũ Việt Thắng on 13/05/2022.
//

import UIKit
import Photos

class ViewController: UIViewController {    
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    
    @IBOutlet private weak var imageCollectionView: UICollectionView!
    
    @IBOutlet private weak var imageSelectionView: UIView!
    @IBOutlet private weak var informLabel: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var selectedImageCollectionView: UICollectionView!
    
    private var isSelected = false
    private var selectedIndexArray = [Int]()
    private var selectedImageCellSize: Int?
    private var images = [PHAsset]()
    
    @IBAction func goBack(_ sender: UIButton){
        isSelected = false
        for value in selectedIndexArray{
            let indexPath = IndexPath(row: value, section: 0)
            let cell = imageCollectionView.cellForItem(at: indexPath) as! CollectionViewCell
            cell.changeChosenCell()
        }
        selectedIndexArray.removeAll()
        self.imageSelectionView.isHidden = true
        self.backButton.isHidden = true
        updateSelectOrder()
    }
    
    private func updateSelectOrder(){
        var order = 1
        for value in selectedIndexArray{
            let indexPath = IndexPath(row: value, section: 0)
            let cell = imageCollectionView.cellForItem(at: indexPath) as! CollectionViewCell
            cell.setPickOrderLabel(order: order)
            order += 1
        }
    }
    
    private func LoadAssetFromPhotos(){
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
                    self.imageCollectionView.reloadData()
                }
            }
        }
    }
    
    //register cells into collection views
    private func collectionViewCellRegister(){
        self.imageCollectionView.register(UINib(nibName: "CollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CollectionViewCell")
        self.selectedImageCollectionView.register(UINib(nibName: "SelectedImageCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SelectedImageCollectionViewCell")
    }
    
    // make button edges round
    private func makeButtonRound(){
        addButton.layer.cornerRadius = addButton.bounds.height / 2
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer){
        switch gesture.state{
        case .began:
            guard let targetIndexPath = selectedImageCollectionView.indexPathForItem(at: gesture.location(in: selectedImageCollectionView)) else {
                return
            }
            selectedImageCollectionView.beginInteractiveMovementForItem(at: targetIndexPath)
        case .changed:
            selectedImageCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: selectedImageCollectionView))
        case .ended:
            selectedImageCollectionView.endInteractiveMovement()
            updateSelectOrder()
        default:
            selectedImageCollectionView.cancelInteractiveMovement()
        }
    }
    
    // allow reordering by longpressing the selected image
    private func addReorderGesture(){
        let gesture = UILongPressGestureRecognizer(target: self, action:#selector(handleLongPressGesture(_:)))
        selectedImageCollectionView.addGestureRecognizer(gesture)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        selectedImageCollectionView.delegate = self
        selectedImageCollectionView.dataSource = self
        
        collectionViewCellRegister()
        makeButtonRound()
        LoadAssetFromPhotos()
        addReorderGesture()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.imageCollectionView{
            return images.count
        }
        else{
            return selectedIndexArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.imageCollectionView{
            let noOfCellInRow = 4
            
            let size = (imageCollectionView.bounds.width - CGFloat(noOfCellInRow + 1)) / CGFloat(noOfCellInRow)
            
            return CGSize(width: size, height: size)
        }
        else{
            let size = collectionView.bounds.height
            return CGSize(width: size, height: size)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.imageCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
            let index = selectedIndexArray.firstIndex(of: indexPath.row)
            cell.createCell(index: index ?? 0, asset: images[indexPath.row])
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedImageCollectionViewCell", for: indexPath) as! SelectedImageCollectionViewCell
            cell.delegate = self
            
            //get the selected image assets
            cell.index = selectedIndexArray[indexPath.row]
            cell.createCell(asset: images[selectedIndexArray[indexPath.row]])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.imageCollectionView{
            let cell = imageCollectionView.cellForItem(at: indexPath) as! CollectionViewCell
            cell.changeChosenCell()
            
            //if image was already selected
            if let index = selectedIndexArray.firstIndex(of: indexPath.row){
                selectedIndexArray.remove(at: index)
                if selectedIndexArray.count == 0{
                    isSelected = false
                    self.imageSelectionView.isHidden = true
                    self.backButton.isHidden = true
                }
            }
            else {
                selectedIndexArray.append(indexPath.row)
                if !isSelected{
                    isSelected = true
                    self.imageSelectionView.isHidden = false
                    self.backButton.isHidden = false
                }
            }
            updateSelectOrder()
            self.selectedImageCollectionView.reloadData()
        }
        else{
            //no function when tap the selected images
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = selectedIndexArray.remove(at: sourceIndexPath.row)
        selectedIndexArray.insert(item, at: destinationIndexPath.row)
    }
}

// MARK: - SelectedImageCollectionViewCellDelegate
extension ViewController: SelectedImageCollectionViewCellDelegate{
    func selectedImageCollectionViewCell(_ cell: SelectedImageCollectionViewCell, didTapDeleteButtonWithIndex index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        let cell = self.imageCollectionView.cellForItem(at: indexPath) as! CollectionViewCell
        cell.changeChosenCell()
        let deletedIndex = selectedIndexArray.firstIndex(of: indexPath.row)
        selectedIndexArray.remove(at: deletedIndex!)
        if selectedIndexArray.count == 0{
            isSelected = false
            self.imageSelectionView.isHidden = true
            self.backButton.isHidden = true
        }
        updateSelectOrder()
        self.selectedImageCollectionView.reloadData()
    }
}
