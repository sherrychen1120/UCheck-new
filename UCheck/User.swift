//
//  User.swift
//  UCheck
//
//  Created by Sherry Chen on 7/5/17.
//
//

import UIKit
import Firebase

var user_id = 0

class User: NSObject {
    var first_name : String = ""
    var last_name : String = ""
    var email : String = ""
    var phone_no : String = ""
    var credit_card_no : String = ""
    var credit_card_ex_date : String = ""
    var credit_card_cvv : String = ""
    var cardholder_name : String = ""
    var billing_add_street : String = ""
    var billing_add_city : String = ""
    var billing_add_zip_code : String = ""
    var billing_add_state : String = ""
    var photo_url : String = ""
    let ref: FIRDatabaseReference?
    let key: String
    
    
    init(first_name : String,
         last_name : String,
         email : String,
         phone_no : String) {
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.phone_no = phone_no
        self.ref = nil
        self.key = ""
    }
    
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key
        self.ref = snapshot.ref
        let snapshotValue = snapshot.value as! [String: AnyObject]
        first_name = snapshotValue["first_name"] as! String
        last_name = snapshotValue["last_name"] as! String
        email = snapshotValue["email"] as! String
        phone_no = snapshotValue["phone_no"] as! String
        credit_card_no = snapshotValue["credit_card_no"] as! String
        credit_card_ex_date = snapshotValue["credit_card_ex_date"] as! String
        credit_card_cvv = snapshotValue["credit_card_cvv"] as! String
        cardholder_name = snapshotValue["cardholder_name"] as! String
        billing_add_street = snapshotValue["billing_add_street"] as! String
        billing_add_city = snapshotValue["billing_add_city"] as! String
        billing_add_zip_code = snapshotValue["billing_add_zip_code"] as! String
        billing_add_state = snapshotValue["billing_add_state"] as! String
        photo_url = snapshotValue["photo_url"] as! String
    }
    
    func toAnyObject() -> Any {
        return [
            "first_name" : first_name,
            "last_name" : last_name,
            "email" : email,
            "phone_no" : phone_no,
            "credit_card_no" : credit_card_no,
            "credit_card_ex_date" : credit_card_ex_date,
            "credit_card_cvv" : credit_card_cvv,
            "cardholder_name" : cardholder_name,
            "billing_add_street" : billing_add_street,
            "billing_add_city" : billing_add_city,
            "billing_add_zip_code" : billing_add_zip_code,
            "billing_add_state" : billing_add_state,
            "photo_url" : photo_url
        ]
    }

}
