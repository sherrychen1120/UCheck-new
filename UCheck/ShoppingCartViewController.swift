//
//  ShoppingCartViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/22/17.
//
//

import UIKit

class ShoppingCartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var StoreNameLabel: UILabel!
    @IBOutlet weak var ShoppingCartTableView: UITableView!
    
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var MembershipSavedLabel: UILabel!
    @IBOutlet weak var SubtotalLabel: UILabel!
    @IBOutlet weak var EstTaxLabel: UILabel!
    @IBOutlet weak var TotalLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        StoreNameLabel.text = CurrentStoreName
        
        ShoppingCartTableView.delegate = self
        ShoppingCartTableView.dataSource = self
        
        let tax = 0.06 * subtotal
        let total = tax + subtotal
        MembershipSavedLabel.text = "Membership saving: $" + String(format: "%.2f", total_saving)
        SubtotalLabel.text = "Subtotal: $" + String(format: "%.2f", subtotal)
        EstTaxLabel.text = "Est. Tax: $" + String(format: "%.2f", tax)
        TotalLabel.text = "Total: $" + String(format: "%.2f", total)

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CurrentShoppingCart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.ShoppingCartTableView.dequeueReusableCell(withIdentifier:"CartItemCell", for: indexPath) as? SmallCartItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of SmallCartItemTableViewCell.")
        }
        
        let item = CurrentShoppingCart[indexPath.row]
        cell.ItemImage.image = item.item_image
        cell.ItemName.text = item.name
        //cell.ItemQuantity = ""
        if item.has_discount {
            cell.ItemPrice.text = "$" + item.discount_price
            cell.ItemOriginalPrice.text = "Original: $" + item.price
            cell.DeleteLine.isHidden = false
        } else {
            cell.ItemPrice.text = "$" + item.price
            cell.ItemOriginalPrice.isHidden = true
            cell.DeleteLine.isHidden = true
        }
                
        return cell
    }
    
    /*func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = CurrentShoppingCart[indexPath.row]
            CurrentShoppingCart.deleteItem(oldItem: s)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            updatePrices()
        }
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
