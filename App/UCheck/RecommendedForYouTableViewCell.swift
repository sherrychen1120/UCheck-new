//
//  RecommendedForYouTableViewCell.swift
//  UCheck
//
//  Created by Sherry Chen on 7/13/17.
//
//

import UIKit
import Firebase
import FirebaseStorage

var ItemwiseRecommendationList : [Item] = []
var ItemwiseRecommendationStoreIds : [String] = []
var ItemwiseRecommendationStoreLogos : [UIImage] = []

class RecommendedForYouTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var GapView: UIView!
    @IBOutlet weak var RecommendationCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        RecommendationCollectionView.delegate = self
        RecommendationCollectionView.dataSource = self
        
        //let topShadow = EdgeShadowLayer(forView: GapView, edge: .Top)
        //GapView.layer.addSublayer(topShadow)
    }
    
    public func reloadRecommendations(){
        DispatchQueue.main.async {
            self.RecommendationCollectionView.reloadData()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendedItemCell", for: indexPath as IndexPath) as! RecommendedItemCollectionViewCell
        
        if (ItemwiseRecommendationList.count > 0){
            let curr_item = ItemwiseRecommendationList[indexPath.row]
            
            if let source_logo = curr_item.store_logo{
                cell.StoreLogo.image = source_logo
            }
            
            if let source_image = curr_item.item_image{
                cell.ItemImage.image = source_image
            }
            cell.ItemName.text = curr_item.name
            if (curr_item.has_itemwise_discount != "none"){
                cell.ItemName.isHidden = false
                cell.ItemPrice.isHidden = false
                cell.ItemOriginalPrice.isHidden = false
                cell.StoreDistance.isHidden = false
                cell.StoreLogo.isHidden = false
                cell.DeleteLine.isHidden = false
                cell.DiscountMessage.isHidden = false
                
                cell.ItemPrice.text = "$" + curr_item.discount_price
                cell.ItemOriginalPrice.text = "$" + curr_item.price
                cell.DiscountMessage.text = curr_item.discount_content
                
            } else if (curr_item.has_coupon != "none"){
                cell.ItemName.isHidden = false
                cell.ItemPrice.isHidden = false
                cell.ItemOriginalPrice.isHidden = false
                cell.StoreDistance.isHidden = false
                cell.StoreLogo.isHidden = false
                cell.DeleteLine.isHidden = false
                cell.DiscountMessage.isHidden = false
                
                cell.ItemPrice.text = "$" + curr_item.coupon_applied_unit_price
                cell.ItemOriginalPrice.text = "$" + curr_item.price
                cell.DiscountMessage.text = curr_item.coupon_content
            } else {
                cell.ItemName.isHidden = false
                cell.ItemPrice.isHidden = false
                cell.StoreDistance.isHidden = false
                cell.StoreLogo.isHidden = false
                
                cell.ItemPrice.text = "$" + curr_item.price
                cell.ItemOriginalPrice.isHidden = true
                cell.DiscountMessage.isHidden = true
                cell.DeleteLine.isHidden = true
            }
        } else {
            cell.ItemName.isHidden = true
            cell.ItemPrice.isHidden = true
            cell.ItemOriginalPrice.isHidden = true
            cell.StoreDistance.isHidden = true
            cell.StoreLogo.isHidden = true
            cell.DeleteLine.isHidden = true
            cell.DiscountMessage.isHidden = true
        }
        
        return cell
    }
    
    
    
}

extension RecommendedForYouTableViewCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let itemsPerRow:CGFloat = 2.5
        let hardCodedPadding:CGFloat = 10
        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding - 5
        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
        
        //print("itemWidth = " + String(describing: itemWidth))
        //print("itemHeight = " + String(describing: itemHeight))
        //print("boundsHeight = " + String(describing: collectionView.bounds.height))
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
}
