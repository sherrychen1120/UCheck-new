//
//  RecommendedItemCollectionViewCell.swift
//  UCheck
//
//  Created by Sherry Chen on 8/2/17.
//
//

import UIKit

class RecommendedItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var ItemImage: UIImageView!
    @IBOutlet weak var ItemName: UILabel!
    @IBOutlet weak var ItemPrice: UILabel!
    @IBOutlet weak var DiscountMessage: UILabel!
    @IBOutlet weak var ItemOriginalPrice: UILabel!
    @IBOutlet weak var DeleteLine: UIView!
    @IBOutlet weak var StoreDistance: UILabel!
    @IBOutlet weak var StoreLogo: UIImageView!
}
