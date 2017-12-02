//
//  HistorySessionTableViewCell.swift
//  UCheck
//
//  Created by Sherry Chen on 12/1/17.
//

import UIKit

class HistorySessionTableViewCell: UITableViewCell {

    @IBOutlet weak var TotalPriceLabel: UILabel!
    @IBOutlet weak var DateTimeLabel: UILabel!
    @IBOutlet weak var StoreLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
