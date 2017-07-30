//
//  RecommendedForYouTableViewCell.swift
//  UCheck
//
//  Created by Sherry Chen on 7/13/17.
//
//

import UIKit

class RecommendedForYouTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var RecommendationCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        RecommendationCollectionView.delegate = self
        RecommendationCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath as IndexPath) 
        return cell
    }
    
}

extension RecommendedForYouTableViewCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let itemsPerRow:CGFloat = 3
        let hardCodedPadding:CGFloat = 10
        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding - 5
        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
        
        //print("itemWidth = " + String(describing: itemWidth))
        //print("itemHeight = " + String(describing: itemHeight))
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
}
