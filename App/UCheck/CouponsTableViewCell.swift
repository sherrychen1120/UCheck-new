//
//  CouponsTableViewCell.swift
//  UCheck
//
//  Created by Sherry Chen on 7/13/17.
//
//

import UIKit

var CouponsToDisplayList: [CouponForDisplay] = []

class CouponsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var CouponsCollectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        CouponsCollectionView.delegate = self
        CouponsCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CouponItemCell", for: indexPath as IndexPath) as! CouponItemCollectionViewCell
        
        if (CouponsToDisplayList.count > 0){
            cell.CouponImage.image = CouponsToDisplayList[indexPath.row].coupon_image
        }
        return cell
    }
    
    public func reloadCoupons(){
        DispatchQueue.main.async{
            self.CouponsCollectionView.reloadData()
        }
    }

}

extension CouponsTableViewCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let hardCodedPadding:CGFloat = 5
        let itemWidth = collectionView.bounds.width - 2 * hardCodedPadding
        let itemHeight = collectionView.bounds.height / 3 - 2 * hardCodedPadding
        
        //print("couponitemWidth = " + String(describing: itemWidth))
        //print("couponitemHeight = " + String(describing: itemHeight))
        //print("couponboundsHeight = " + String(describing: collectionView.bounds.height))
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
}

