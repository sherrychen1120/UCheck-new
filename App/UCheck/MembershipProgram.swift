//
//  MembershipProgram.swift
//  UCheck
//
//  Created by Sherry Chen on 8/21/17.
//
//

import UIKit
import Firebase

class MembershipProgram: NSObject {
    var store_name = ""
    var points = 0
    var savings_this_month = ""
    var spending_this_month = ""
    var promo_message = ""
    var store_logo : UIImage?
    
    init(store_name_source : String, snapshot_source : FIRDataSnapshot){
        print(snapshot_source)
        store_name = store_name_source
        let snapshotValue = snapshot_source.value as! [String:AnyObject]
        points = snapshotValue["points"] as! Int
        savings_this_month = snapshotValue["savings_this_month"] as! String
        spending_this_month = snapshotValue["spending_this_month"] as! String
        promo_message = snapshotValue["promo_message"] as! String
    }
    
    func addLogo(image_source : UIImage?){
        store_logo = image_source
    }
}
