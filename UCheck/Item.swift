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
    var name : String = ""
    var price : String = ""
    var has_discount = false
    var discount_message : String = ""
    var discount_price : String = ""
    let ref: FIRDatabaseReference?
    
    init(code:String, name:String, price:String,
         has_discount:Bool, discount_message:String, discount_price:String) {
        self.code = code
        self.name = name
        self.price = price
        self.has_discount = has_discount
        self.discount_message = discount_message
        self.discount_price = discount_price
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        code = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        price = snapshotValue["price"] as! String
        has_discount = snapshotValue["has_discount"] as! Bool
        discount_message = snapshotValue["discount_message"] as! String
        discount_price = snapshotValue["discount_price"] as! String
        ref = snapshot.ref
    }


}
