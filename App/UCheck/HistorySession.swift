//
//  HistorySession.swift
//  UCheck
//
//  Created by Sherry Chen on 12/1/17.
//

import UIKit
import Firebase

class HistorySession: NSObject {
    var date_time = ""
    var store_id = ""
    var items_bought : [item_lite] = []
    var total = ""
    
    init(session_id : String, dict: NSDictionary){
        //Extract date_time
        let indexStart = session_id.index(session_id.endIndex, offsetBy: -15)
        date_time = String(session_id[indexStart...])
        
        //Extract store_id & total
        store_id = dict["store_id"] as! String
        total = dict["total"] as! String
        
        //Extract the list of items_bought, with each item saved as a struct item_lite
        let history_items = dict["items_bought"] as! NSDictionary
        let all_item_numbers = history_items.allKeys as! [String]
        for item_number in all_item_numbers {
            let q = history_items[item_number] as! NSNumber
            print("item_number: " + item_number + "; quantity: " + String(describing: q))
            let new_item = item_lite(item_number: item_number, quantity: String(describing: q))
            items_bought.append(new_item)
        }
    }
    
    
}
struct item_lite {
    var item_number = ""
    var quantity = ""
}

