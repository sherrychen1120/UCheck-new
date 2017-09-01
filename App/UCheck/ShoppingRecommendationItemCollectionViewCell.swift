//
//  ShoppingRecommendationItemCollectionViewCell.swift
//  UCheck
//
//  Created by Sherry Chen on 9/1/17.
//
//

import UIKit

class ShoppingRecommendationItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var ItemImage: UIImageView!
    
    @IBOutlet weak var PromoMessage: UILabel!
    @IBOutlet weak var DeleteLine: UIView!
    @IBOutlet weak var OriginalPrice: UILabel!
    @IBOutlet weak var ItemPrice: UILabel!
}
