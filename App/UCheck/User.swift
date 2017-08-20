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
    var uid : String = ""
    var first_name : String = ""
    var last_name : String = ""
    var email : String = ""
    var phone_no : String = ""
    var credit_card_no : String = ""
    var credit_card_ex_month : String = ""
    var credit_card_ex_year : String = ""
    var credit_card_cvv : String = ""
    var cardholder_first_name : String = ""
    var cardholder_last_name : String = ""
    var billing_add_street : String = ""
    var billing_add_extended : String = ""
    var billing_add_city : String = ""
    var billing_add_zip_code : String = ""
    var billing_add_state : String = ""
    var photo_url : String = ""
    let ref: FIRDatabaseReference?
    let key: String
    
    init(uid : String,
         first_name : String,
         last_name : String,
         email : String,
         phone_no : String) {
        self.uid = uid
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
        uid = snapshotValue["uid"] as! String
        first_name = snapshotValue["first_name"] as! String
        last_name = snapshotValue["last_name"] as! String
        email = snapshotValue["email"] as! String
        phone_no = snapshotValue["phone_no"] as! String
        /*credit_card_no = snapshotValue["credit_card_no"] as! String
        credit_card_ex_month = snapshotValue["credit_card_ex_date"] as! String
        credit_card_ex_year = snapshotValue["credit_card_ex_date"] as! String
        credit_card_cvv = snapshotValue["credit_card_cvv"] as! String
        cardholder_first_name = snapshotValue["cardholder_first_name"] as! String
        cardholder_last_name = snapshotValue["cardholder_last_name"] as! String
        billing_add_street = snapshotValue["billing_add_street"] as! String
        billing_add_extended = snapshotValue["billing_add_extended"] as! String
        billing_add_city = snapshotValue["billing_add_city"] as! String
        billing_add_zip_code = snapshotValue["billing_add_zip_code"] as! String
        billing_add_state = snapshotValue["billing_add_state"] as! String*/
        photo_url = snapshotValue["photo_url"] as! String
    }
    
    //the function to turn into a user object on Firebase. Only contains non-sensitive information.
    func toAnyObject() -> Any {
        return [
            "uid" : uid,
            "first_name" : first_name,
            "last_name" : last_name,
            "email" : email,
            "phone_no" : phone_no,
            "photo_url" : photo_url
        ]
    }
    
    func add_payment_info(credit_card_no : String, credit_card_ex_month : String,
                          credit_card_ex_year : String, credit_card_cvv : String){
        self.credit_card_no = credit_card_no
        self.credit_card_ex_month = credit_card_ex_month
        self.credit_card_ex_year = credit_card_ex_year
        self.credit_card_cvv = credit_card_cvv

    }
    
    func add_billing_info(cardholder_first_name : String, cardholder_last_name : String,
                          billing_add_street : String, billing_add_extended : String,
                          billing_add_city : String, billing_add_zip_code : String,
                          billing_add_state : String){
        self.cardholder_first_name = cardholder_first_name
        self.cardholder_last_name = cardholder_last_name
        self.billing_add_street = billing_add_street
        self.billing_add_extended = billing_add_extended
        self.billing_add_city = billing_add_city
        self.billing_add_zip_code = billing_add_zip_code
        self.billing_add_state = billing_add_state
    }


}
