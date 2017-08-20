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
    var category : String = ""
    var has_itemwise_discount = "none"
    var has_coupon = "none"
    var discount_content : String = ""
    var discount_price : String = ""
    var coupon_id : String = ""
    var coupon_content : String = ""
    var coupon_image_url : String = ""
    var coupon_applied_unit_price : String = ""
    var item_image : UIImage?
    var quantity : Int = 1
    let ref: FIRDatabaseReference?
    
    //Is this even used anywhere??
    init(code:String, name:String, price:String, category:String,
         has_itemwise_discount:String, has_coupon:String) {
        self.code = code
        self.name = name
        self.price = price
        self.category = category
        self.has_itemwise_discount = has_itemwise_discount
        self.has_coupon = has_coupon
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        code = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        price = snapshotValue["price"] as! String
        category = snapshotValue["category"] as! String
        has_itemwise_discount = snapshotValue["has_itemwise_discount"] as! String
        has_coupon = snapshotValue["has_coupon"] as! String
        
        
        if (has_itemwise_discount != "none")  {
            let itemwise_discount = snapshotValue["itemwise_discount"] as! [String:AnyObject]
            discount_content = itemwise_discount["discount_content"] as! String
            discount_price = itemwise_discount["discount_price"] as! String
        }
        
        if (has_coupon != "none")  {
            let coupons = snapshotValue["coupons"] as! NSDictionary
            let coupon_ids = coupons.allKeys
            if (coupon_ids.count == 1){
                coupon_id = coupon_ids[0] as! String
                let coupon = coupons[coupon_id] as! NSDictionary
                coupon_content = coupon["coupon_content"] as! String
                coupon_image_url = coupon["coupon_image_url"] as! String
                coupon_applied_unit_price = coupon["coupon_applied_unit_price"] as! String
            } else {
                print("Database error - more than one coupon on one item.")
            }
        }
        
        ref = snapshot.ref
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


}
