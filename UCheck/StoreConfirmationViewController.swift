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
    let ref = FIRDatabase.database().reference(withPath: "membership-programs")

    @IBOutlet weak var YesButton: UIButton!
    @IBOutlet weak var StoreNameLabel: UILabel!
    @IBOutlet weak var StoreAddressLabel: UILabel!
    @IBAction func YesButton(_ sender: Any) {
        CurrentStore = store_id
        OnGoing = true
        
        ref.child(store_name).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get store information
            let value = snapshot.value as? NSDictionary
            
            
            if (self.store_name != "" && self.store_address != ""){
                print(self.store_name)
                print(self.store_address)
                self.performSegue(withIdentifier: "ScanStoreCodeToStoreConfirmation", sender: self)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }

        /*Read from database whether CurrentUser is in the membership program of CurrentStore.
         If yes - log in to the program
        IsMember = true
        performSegue(withIdentifier: "StoreConfirmationToMembership", sender: nil)
         if no - register for the program
        performSegue(withIdentifier: "StoreConfirmationToJoinMember", sender: nil)
         */
 
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
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
