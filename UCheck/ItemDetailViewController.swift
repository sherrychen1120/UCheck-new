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
    var currItem : Item = Item(code: "", name: "", price: "", has_discount: false, discount_message: "", discount_price: "")
    
    @IBOutlet weak var ItemNameLabel: UILabel!
    @IBOutlet weak var ItemPriceLabel: UILabel!
    @IBOutlet weak var ItemImage: UIImageView!
    @IBOutlet weak var ContinueButton: UIButton!
    
    @IBAction func ContinueButton(_ sender: Any) {
    }
    @IBAction func CancelButton(_ sender: Any) {
        if let delegate = transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        performSegue(withIdentifier: "ItemDetailToScanning", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ContinueButton.layer.cornerRadius = 9
        
        //display item detail information
        ItemNameLabel.text = currItem.name
        if (currItem.has_discount) {
            ItemPriceLabel.text = "$" + (currItem.discount_price)
        } else {
            ItemPriceLabel.text = "$" + (currItem.price)
        }
        
        //TODO: display image
        let storage = FIRStorage.storage()
        let code = currItem.code
        let storageRef = storage.reference(withPath: "inventory/\(CurrentStore)/\(code).png")
        
        storageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let image = UIImage(data: data!)
                self.ItemImage.image = image
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
