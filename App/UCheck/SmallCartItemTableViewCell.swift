//
//  SmallCartItemTableViewCell.swift
//  UCheck
//
//  Created by Sherry Chen on 7/22/17.
//
//

import UIKit

//Delegate for updating table view from the cell
protocol CustomCellUpdater {
    func updateTableView()
}

class SmallCartItemTableViewCell: UITableViewCell, CustomCellUpdater {

    @IBOutlet weak var ItemImage: UIImageView!
    @IBOutlet weak var ItemName: UILabel!
    @IBOutlet weak var ItemPrice: UILabel!
    @IBOutlet weak var ItemQuantity: UILabel!
    
    var currItem : Item?
    var delegate: CustomCellUpdater?
    
    /*@IBAction func DecreaseQuantityButton(_ sender: Any) {
        print("decrease clicked")
        ShoppingCart.deleteItem(oldItem: currItem!)
        updateTableView()
    }*/
    
    /*@IBAction func IncreaseQuantityButton(_ sender: Any) {
        print("increase clicked")
        ShoppingCart.addItem(newItem: currItem!)
        updateTableView()
    }*/

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func updateTableView() {
        delegate?.updateTableView()
    }

}
