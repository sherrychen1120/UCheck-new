//
//  StoreConfirmationViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/15/17.
//
//

import UIKit
import Firebase

class StoreConfirmationViewController: UIViewController {
    
    var store_id = ""
    var store_name = ""
    var store_address = ""
    var phone_no = ""
    let ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var YesButton: UIButton!
    @IBOutlet weak var StoreNameLabel: UILabel!
    @IBOutlet weak var StoreAddressLabel: UILabel!
    @IBAction func YesButton(_ sender: Any) {
        CurrentStore = store_id
        OnGoing = true
        print("CurrentStore =" + store_id)
        print("OnGoing = true")
        
        //Log in to membership program
        ref.child("membership-programs").child(store_name).observeSingleEvent(of: .value, with: { (snapshot) in
            // Read from database whether CurrentUser is in the membership program of CurrentStore.
            let dict = snapshot.value as? NSDictionary
            
            //Read the phone number for current user
            let userID = FIRAuth.auth()?.currentUser?.uid
            self.ref.child("user-profiles").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                self.phone_no = value?["phone_no"] as! String
                print(self.phone_no)
                
                //Check the phone number in membership databse
                if dict![self.phone_no] != nil {
                    //if yes - get the user's phone number and log in to the program
                    IsMember = true
                    print("IsMember = true")
                    self.performSegue(withIdentifier: "StoreConfirmationToMembership", sender: nil)
                } else {
                    //if no - register for the program
                    self.performSegue(withIdentifier: "StoreConfirmationToJoinMember", sender: nil)
                }

            }) { (error) in
                print(error.localizedDescription)
            }
            
            print("out of the first ref")
        
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //Braintree client token
        
        
    }
    @IBAction func BackButton(_ sender: Any) {
        performSegue(withIdentifier: "UnwindToScanStore", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.backgroundColor = UIColor(red:0.53, green:0.05, blue:0.05, alpha:1.0)
        YesButton.layer.cornerRadius = 9
        
        StoreNameLabel.text = store_name + "?"
        StoreAddressLabel.text = store_address
        
        CurrentStoreName = store_name
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StoreConfirmationToJoinMember"{
            let nextScene = segue.destination as? JoinMemberViewController
            nextScene?.phone_no = self.phone_no
            nextScene?.store_name = self.store_name
        }
    }

}
