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
    private var selectedImages = [PHAsset]()
    private var selectedImageCellSize: Int?
    private var assets = [PHAsset]()

    func animateShow(view: UIView){
        UIView.animate(withDuration: 0.5, animations: {
            view.transform = CGAffineTransform(translationX: 0, y: -(view.bounds.height))
        }, completion: nil)
    }
    func animateHide(view: UIView){
        UIView.animate(withDuration: 0.5, animations: {
            view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
    }
    
    func hideImageSelectionView(){
        isSelected = false
        animateHide(view: self.imageSelectionView)
        self.backButton.isHidden = true
    }
    func showImageSelectionView(){
        isSelected = true
        animateShow(view: self.imageSelectionView)
        self.backButton.isHidden = false
    }
    
    @IBAction func goBack(_ sender: UIButton){
        for value in selectedImages{
            let index = assets.firstIndex(of: value)
            let indexPath = IndexPath(row: index!, section: 0)
            let cell = imageCollectionView.cellForItem(at: indexPath) as! CollectionViewCell
            cell.changeChosenCell()
        }
        selectedImages.removeAll()
        hideImageSelectionView()
        updateSelectOrder()
    }
    
    private func updateSelectOrder(){
        var order = 1
        for value in selectedImages{
            let index = assets.firstIndex(of: value)
            let indexPath = IndexPath(row: index!, section: 0)
            let cell = imageCollectionView.cellForItem(at: indexPath) as! CollectionViewCell
            cell.setPickOrderLabel(order: order)
            order += 1
        }
    }
    
    private func loadAssetFromPhotos(handleClosure: @escaping (() -> Void)){
        PHPhotoLibrary.requestAuthorization{ status in
            if status == .authorized {
                let imageAssets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
                imageAssets.enumerateObjects{ (object, _, _) in
                    self.assets.append(object)
                }
                let videoAssets = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: nil)
                videoAssets.enumerateObjects{ (object, _, _) in
                    self.assets.append(object)
                }
                DispatchQueue.main.async {
                    handleClosure()
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
        addReorderGesture()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func willEnterForeground(){
        assets.removeAll()

        let enterForegroundHandle = { [self] in
            for value in selectedImages{
                if assets.firstIndex(of: value) == nil{
                    let selectedIndex = selectedImages.firstIndex(of: value)
                    selectedImages.remove(at: selectedIndex!)
                }
            }
            
            self.imageCollectionView.reloadData()
            self.selectedImageCollectionView.reloadData()
            
            if selectedImages.count == 0 {
                isSelected = false
                self.imageSelectionView.isHidden = true
                self.backButton.isHidden = true
                updateSelectOrder()
            }
        }
        
        loadAssetFromPhotos(handleClosure: enterForegroundHandle)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.imageCollectionView{
            return assets.count
        }
        else{
            return selectedImages.count
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
            let imageAsset = assets[indexPath.row]
            let index = (selectedImages.firstIndex(of: imageAsset) != nil) ? (selectedImages.firstIndex(of: imageAsset)! + 1) : 0
            cell.createCell(index: index, asset: imageAsset)
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedImageCollectionViewCell", for: indexPath) as! SelectedImageCollectionViewCell
            cell.delegate = self
            
            //get the selected image assets

            cell.index = indexPath.row
            cell.createCell(asset: selectedImages[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.imageCollectionView{
            let cell = imageCollectionView.cellForItem(at: indexPath) as! CollectionViewCell
            cell.changeChosenCell()
            
            let imageAsset = assets[indexPath.row]
            
            //if image was already selected
            if let index = selectedImages.firstIndex(of: imageAsset){
                selectedImages.remove(at: index)
                if selectedImages.count == 0{
                    hideImageSelectionView()
                }
            }
            else {
                selectedImages.append(imageAsset)
                if !isSelected{
                    showImageSelectionView()
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
        let item = selectedImages.remove(at: sourceIndexPath.row)
        selectedImages.insert(item, at: destinationIndexPath.row)
    }
}

// MARK: - SelectedImageCollectionViewCellDelegate
extension ViewController: SelectedImageCollectionViewCellDelegate{
    func selectedImageCollectionViewCell(_ cell: SelectedImageCollectionViewCell, didTapDeleteButtonWithIndex index: Int) {
        let imageAsset = selectedImages[index]
        let indexPath = IndexPath(row: assets.firstIndex(of: imageAsset)!, section: 0)
        let cell = self.imageCollectionView.cellForItem(at: indexPath) as! CollectionViewCell
        cell.changeChosenCell()
        selectedImages.remove(at: index)
        if selectedImages.count == 0{
            hideImageSelectionView()
        }
        updateSelectOrder()
        self.selectedImageCollectionView.reloadData()
    }
}
