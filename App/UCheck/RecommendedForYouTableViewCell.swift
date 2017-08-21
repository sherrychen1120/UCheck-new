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

    @IBOutlet weak var RecommendationCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        RecommendationCollectionView.delegate = self
        RecommendationCollectionView.dataSource = self
        
        //Get items & pictures and refresh
        self.getItems(handleComplete:{
            self.getPictures(handleComplete:{
                DispatchQueue.main.async {
                    self.RecommendationCollectionView.reloadData()
                }
            })
        })

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendedItemCell", for: indexPath as IndexPath) as! RecommendedItemCollectionViewCell
        
        if (ItemwiseRecommendationList.count > 0){
            let curr_item = ItemwiseRecommendationList[indexPath.row]
            
            //fill in store logo
            let curr_store_id = curr_item.store_id
            let c = curr_store_id.characters
            let divider = c.index(of: "_")!
            
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
    
    
    func getItems(handleComplete:@escaping (()->())){
        let uid = CurrentUserId
        let recom_ref = FIRDatabase.database().reference(withPath: "user-profiles/\(uid)/itemwise_recommendation")
        
        //Read objects from Firebase
        recom_ref.observe(.value, with: { snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            //print(snapshotValue)
            
            //sort all the scores in ascending order
            let allBarcodes = snapshotValue.allKeys as! [String]
            
            //Retrieve all the items, put them into the array
            for barcode in allBarcodes {
                let recom_item_dict = snapshotValue[barcode] as! [String:AnyObject]
                //print(recom_item_dict)
                let recom_item = Item(snapshotValue: recom_item_dict, barcode: barcode)
                let store_id = recom_item.store_id
                
                ItemwiseRecommendationList.append(recom_item)
                if (!ItemwiseRecommendationStoreIds.contains(store_id)){
                    ItemwiseRecommendationStoreIds.append(store_id)
                }
            }
            
            ItemwiseRecommendationList.sort{ $0.score > $1.score}
            
            handleComplete()
            
        })
        
    }
    
    func getPictures(handleComplete:@escaping (()->())){
        for item in ItemwiseRecommendationList{
            let item_bar_code = item.code
            let store_id = item.store_id
            
            let image_ref = FIRStorage.storage().reference(withPath:"inventory/\(store_id)/\(item_bar_code).png")
            
            image_ref.data(withMaxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    let image = UIImage(data: data!)
                    item.addImage(source: image)
                    print("Image saved for \(item.name)")
                    
                    self.getStoreLogo(store_id:store_id, item:item)
                }
            }
        }
        
        handleComplete()
    }
    
    func getStoreLogo(store_id: String, item: Item){
        
            let c = store_id.characters
            let divider = c.index(of: "_")!
            let store_name = store_id[store_id.startIndex..<divider]
            
            let image_ref = FIRStorage.storage().reference(withPath:"store_logos/\(store_name).png")
            
            image_ref.data(withMaxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    let image = UIImage(data: data!)
                    item.addStoreLogo(source: image)
                    print("Store logo saved for \(store_name)")
                }
            }
        
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
