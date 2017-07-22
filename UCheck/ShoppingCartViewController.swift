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

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CurrentShoppingCart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier:"CartItemCell", for: indexPath) as? CartItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of CartItemTableViewCell.")
        }
        
        let s = shoppingCart[indexPath.row]
        cell.ItemName?.text = s.name
        cell.ItemDetails?.text = "Color: " + s.color + ", Size: " + s.size
        cell.ItemPrice?.text = "$" + s.price
        
        let ItemCode = s.code
        let storageRef = storage.reference(withPath: "\(ItemCode)-2.jpeg")
        
        storageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let image = UIImage(data: data!)
                cell.ItemImage?.image = image
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let s = shoppingCart[indexPath.row]
            ShoppingCart.deleteItem(oldItem: s)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            updatePrices()
        }
    }

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
