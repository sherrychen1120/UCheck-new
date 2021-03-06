//
//  Item.swift
//  UCheck
//
//  Created by Sherry Chen on 7/18/17.
//
//

import UIKit
import Firebase

class Item: NSObject {
    var code : String = ""
    var item_number : String = ""
    var item_name : String = ""
    var item_price : String = ""
    var category : String = ""
    var item_image : UIImage?
    var quantity : Int = 1
    var ref: FIRDatabaseReference? = nil
    
    //Is this even used anywhere??
    init(number:String, code:String, name:String, price:String, category:String) {
        self.item_number = number
        self.code = code
        self.item_name = name
        self.item_price = price
        self.category = category
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.item_number = snapshot.key
        let snapshotValue = snapshot.value as! NSDictionary
        category = snapshotValue["category"] as! String
        code = snapshotValue["barcode"] as? String ?? "-"
        item_name = snapshotValue["item_name"] as! String
        
        if let snap_price = snapshotValue["item_price"] as? NSNumber {
            item_price = String(format: "%.2f", snap_price)
        } else if let snap_price = snapshotValue["item_price"] as? String {
            item_price = snap_price
        }
        
        ref = snapshot.ref
    }
    
    init(snapshotValue: [String:AnyObject], item_number:String) {
        self.item_number = item_number
        code = snapshotValue["barcode"] as! String
        item_name = snapshotValue["item_name"] as! String
        if let snap_price = snapshotValue["item_price"] as? NSNumber {
            item_price = String(format: "%.2f", snap_price)
        } else if let snap_price = snapshotValue["item_price"] as? String {
            item_price = snap_price
        }
        category = snapshotValue["category"] as! String
    }

    
    func addImage(source : UIImage?){
        item_image = source
    }
    
    func addItem(){
        quantity = quantity + 1
    }
    
    func deleteItem() -> Int {
        quantity = quantity - 1
        return quantity
    }
    
    func setQuantity(q: Int){
        quantity = q
    }

}
