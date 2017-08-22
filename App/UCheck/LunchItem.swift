//
//  LunchItem.swift
//  UCheck
//
//  Created by Sherry Chen on 8/21/17.
//
//

import UIKit
import Firebase

class LunchItem: NSObject {
    var content : String = ""
    var store_id : String = ""
    var code : String = ""
    var image : UIImage?
    
    init(content_source : String, store_id_source : String, code_source : String){
        content = content_source
        store_id = store_id_source
        code = code_source
        image = nil
    }
    
    init(snapshot_source : FIRDataSnapshot){
        let snapshotValue = snapshot_source.value as! [String:AnyObject]
        content = snapshotValue["content"] as! String
        store_id = snapshotValue["store_id"] as! String
        code = snapshot_source.key
        image = nil
    }
    
    func addImage(image_source : UIImage?){
        image = image_source
    }
}
