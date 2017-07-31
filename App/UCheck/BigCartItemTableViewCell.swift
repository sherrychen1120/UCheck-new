//
//  BigCartItemTableViewCell.swift
//  UCheck
//
//  Created by Sherry Chen on 7/23/17.
//
//

import UIKit

class BigCartItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ItemImage: UIImageView!
    @IBOutlet weak var ItemName: UILabel!
    @IBOutlet weak var ItemQuantity: UILabel!
    @IBOutlet weak var ItemPrice: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
