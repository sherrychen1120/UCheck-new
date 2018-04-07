//
//  AccountMenuTableViewCell.swift
//  UCheck
//
//  Created by Ezaan Mangalji on 2018-01-09.
//

import UIKit

class AccountMenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var value: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
