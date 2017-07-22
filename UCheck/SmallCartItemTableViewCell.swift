//
//  SmallCartItemTableViewCell.swift
//  UCheck
//
//  Created by Sherry Chen on 7/22/17.
//
//

import UIKit

class SmallCartItemTableViewCell: UITableViewCell {

    @IBOutlet weak var ItemImage: UIImageView!
    @IBOutlet weak var ItemName: UILabel!
    @IBOutlet weak var ItemQuantity: UILabel!
    @IBOutlet weak var ItemPrice: UILabel!
    @IBOutlet weak var ItemOriginalPrice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
