//
//  MyRewardsTableViewCell.swift
//  UCheck
//
//  Created by Sherry Chen on 7/13/17.
//
//

import UIKit

var MembershipList : [MembershipProgram] = []

class MyRewardsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var MyRewardsCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        MyRewardsCollectionView.delegate = self
        MyRewardsCollectionView.dataSource = self

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyRewardsItemCell", for: indexPath as IndexPath) as! MyRewardsCollectionViewCell
        
        if (MembershipList.count > 0){
            let curr_membership = MembershipList[indexPath.row]
            if let logo = curr_membership.store_logo{
                cell.StoreLogo.image = logo
            }
            cell.PointsNumber.text = String(curr_membership.points)
            cell.SavingsThisMonthNumber.text = "$" + curr_membership.savings_this_month
            cell.MemberMessage.text = curr_membership.promo_message
        }
        return cell
    }
    
    public func reloadRewards(){
        DispatchQueue.main.async{
            self.MyRewardsCollectionView.reloadData()
        }
    }


}

extension MyRewardsTableViewCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let hardCodedPadding:CGFloat = 5
        let itemWidth = collectionView.bounds.width - 4 * hardCodedPadding
        let itemHeight = collectionView.bounds.height / 2 - 2 * hardCodedPadding
        
        print("rewardsitemWidth = " + String(describing: itemWidth))
        print("rewardsitemHeight = " + String(describing: itemHeight))
        print("rewardsboundsHeight = " + String(describing: collectionView.bounds.height))
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
}

