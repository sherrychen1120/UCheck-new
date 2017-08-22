//
//  LunchNearbyTableViewCell.swift
//  UCheck
//
//  Created by Sherry Chen on 7/13/17.
//
//

import UIKit

var LunchNearbyList : [LunchItem] = []

class LunchNearbyTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var LunchNearbyCollectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        LunchNearbyCollectionView.delegate = self
        LunchNearbyCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LunchNearbyItemCell", for: indexPath as IndexPath) as! LunchNearbyCollectionViewCell
        
        if (LunchNearbyList.count > 0){
            
            cell.LunchName.isHidden = false
            cell.LunchDistance.isHidden = false
            
            let curr_lunch_item = LunchNearbyList[indexPath.row]
            cell.LunchName.text = curr_lunch_item.content
            if let image = curr_lunch_item.image {
                cell.LunchImage.image = image
            }
            
        } else {
            cell.LunchName.isHidden = true
            cell.LunchDistance.isHidden = true

        }
        return cell
    }
    
    public func reloadLunch(){
        DispatchQueue.main.async{
            self.LunchNearbyCollectionView.reloadData()
        }        
    }

}

extension LunchNearbyTableViewCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let itemsPerRow:CGFloat = 2
        let hardCodedPadding:CGFloat = 10
        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding - 5
        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
        
        //print("itemWidth = " + String(describing: itemWidth))
        //print("itemHeight = " + String(describing: itemHeight))
        //print("boundsHeight = " + String(describing: collectionView.bounds.height))
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
}

