//
//  ViewController.swift
//  SelectImage
//
//  Created by Vũ Việt Thắng on 13/05/2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var imageCollection: UICollectionView!
    
    @IBOutlet weak var imageSelectionView: UIView!
    @IBOutlet weak var informLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var isSelected = false
    var selectedArray = [Int]()
    var cellSize: Int?
    
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
    
    func updateSelectOrder(){
        var order = 1
        for value in selectedArray{
            let indexPath = IndexPath(row: value, section: 0)
            let cell = imageCollection.cellForItem(at: indexPath) as! CollectionViewCell
            cell.pickOrderLabel.text = "\(order)"
            order += 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageCollection.delegate = self
        imageCollection.dataSource = self
        self.imageCollection.register(UINib(nibName: "CollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CollectionViewCell")
        //view.addSubview(imageCollection)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 4

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        
        cellSize = size
        return CGSize(width: size, height: size)
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        let index = selectedArray.firstIndex(of: indexPath.row)
        cell.cellSize = cellSize
        cell.createCell(index: index ?? -1)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    }
}

