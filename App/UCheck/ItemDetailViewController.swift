//
//  ItemDetailViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/17/17.
//
//

import UIKit
import Firebase


class ItemDetailViewController: UIViewController, HalfModalPresentable {

    //take the item code from the last VC and create an object with the JSON
    var currItem : Item = Item(code: "", name: "", price: "", category: "", has_itemwise_discount: "none", has_coupon: "none")
    
    @IBOutlet weak var ItemNameLabel: UILabel!
    @IBOutlet weak var ItemPriceLabel: UILabel!
    @IBOutlet weak var ItemImage: UIImageView!
    @IBOutlet weak var ContinueButton: UIButton!
    @IBOutlet weak var OriginalPriceLabel: UILabel!
    @IBOutlet weak var DiscountMessageLabel: UILabel!
    @IBOutlet weak var DeleteLine: UIView!
    
    @IBAction func ContinueButton(_ sender: Any) {
        if let delegate = transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        performSegue(withIdentifier: "ItemDetailToScanning", sender: self)
    }
    
    @IBAction func CancelButton(_ sender: Any) {
        if let delegate = transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        ShoppingCart.deleteItem(oldItem: currItem)
        ShoppingCart.listItems()
        
        performSegue(withIdentifier: "ItemDetailToScanning", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ContinueButton.layer.cornerRadius = 9
        
        //display item detail information
        ItemNameLabel.text = currItem.name
        if (currItem.has_itemwise_discount != "none") {
            ItemPriceLabel.text = "$" + String(currItem.discount_price)
            OriginalPriceLabel.text = "Original: $" + String(currItem.price)
            DiscountMessageLabel.text = currItem.discount_content
        } else if (currItem.has_coupon != "none"){
            ItemPriceLabel.text = "$" + String(currItem.price)
            OriginalPriceLabel.isHidden = true
            DeleteLine.isHidden = true
            DiscountMessageLabel.text = "Related Coupon: " + currItem.coupon_content
        } else {
            ItemPriceLabel.text = "$" + String(currItem.price)
            OriginalPriceLabel.isHidden = true
            DeleteLine.isHidden = true
            DiscountMessageLabel.isHidden = true
        }
        
        //display image
        let storage = FIRStorage.storage()
        let code = currItem.code
        let storageRef = storage.reference(withPath: "inventory/\(CurrentStore)/\(code).png")
        
        storageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let image = UIImage(data: data!)
                self.ItemImage.image = image
                self.currItem.addImage(source: image)
                print("Image saved for \(self.currItem.name)")
            }
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
