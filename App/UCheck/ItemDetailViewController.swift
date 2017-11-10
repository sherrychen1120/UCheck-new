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
    var currItem : Item = Item(number: "", code: "", name: "", price: "", category: "")
    
    @IBOutlet weak var ItemNameLabel: UILabel!
    @IBOutlet weak var ItemPriceLabel: UILabel!
    @IBOutlet weak var ItemImage: UIImageView!
    @IBOutlet weak var ContinueButton: UIButton!
    @IBOutlet weak var OriginalPriceLabel: UILabel!
    
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
        ItemNameLabel.text = currItem.item_name
        ItemPriceLabel.text = "$" + String(currItem.item_price)
        
        //display image
        let storage = FIRStorage.storage()
        var code = currItem.code
        if (code == "-"){
            code = currItem.item_number
        }
        
        let storageRef = storage.reference(withPath: "inventory/\(CurrentStore)/\(code).jpg")
        
        storageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let image = UIImage(data: data!)
                self.ItemImage.image = image
                self.currItem.addImage(source: image)
                print("Image saved for \(self.currItem.item_name)")
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
