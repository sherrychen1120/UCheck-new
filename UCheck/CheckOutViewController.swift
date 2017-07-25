//
//  CheckOutViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/23/17.
//
//

import UIKit

class CheckOutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func ChangePaymentMethodButton(_ sender: Any) {
    }
    @IBAction func ConfirmAndPayButton(_ sender: Any) {
    }
    @IBOutlet weak var ConfirmAndPayButton: UIButton!
    @IBOutlet weak var TotalLabel: UILabel!
    @IBOutlet weak var EstTaxLabel: UILabel!
    @IBOutlet weak var SubtotalLabel: UILabel!
    @IBOutlet weak var MembershipSavedLabel: UILabel!
    @IBOutlet weak var ButtonArea: UIView!
    @IBOutlet weak var CartItemsTableView: UITableView!
    
    @IBAction func BackButton(_ sender: Any) {
        performSegue(withIdentifier: "UnwindToScanner", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Customize the navigation bar
        self.navigationController!.navigationBar.backgroundColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController!.navigationBar.barTintColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController!.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 19)!]
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        //Customize the button
        ConfirmAndPayButton.layer.cornerRadius = 9
        
        //Shadow of the UIView around the button
        ButtonArea.layer.shadowColor = UIColor.black.cgColor
        ButtonArea.layer.shadowOpacity = 0.3
        ButtonArea.layer.shadowOffset = CGSize(width: 0, height: -5)
        ButtonArea.layer.shadowRadius = 3

        //TableView delegate & data source
        CartItemsTableView.delegate = self
        CartItemsTableView.dataSource = self
        
        updatePrices()
    }
    
    func updatePrices(){
        let tax = 0.06 * subtotal
        let total = tax + subtotal
        MembershipSavedLabel.text = "Membership saving: $" + String(format: "%.2f", total_saving)
        SubtotalLabel.text = "Subtotal: $" + String(format: "%.2f", subtotal)
        EstTaxLabel.text = "Est. Tax: $" + String(format: "%.2f", tax)
        TotalLabel.text = "Total: $" + String(format: "%.2f", total)
        ShoppingCart.listItems() //for debug
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CurrentShoppingCart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.CartItemsTableView.dequeueReusableCell(withIdentifier:"CartItemCell", for: indexPath) as? BigCartItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of BigCartItemTableViewCell.")
        }
        
        let item = CurrentShoppingCart[indexPath.row]
        cell.ItemImage.image = item.item_image
        cell.ItemName.text = item.name
        cell.ItemQuantity.text = "×" + String(item.quantity)
        if item.has_discount {
            let item_subtotal = Double(item.discount_price)! * Double(item.quantity)
            cell.ItemPrice.text = "$" + String(item_subtotal)
        } else {
            let item_original_subtotal = Double(item.price)! * Double(item.quantity)
            cell.ItemPrice.text = "$" + String(item_original_subtotal)
        }
        
        return cell
    }
    
    /*func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = CurrentShoppingCart[indexPath.row]
            ShoppingCart.deleteItem(oldItem: item)
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
