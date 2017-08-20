//
//  JoinMemberViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/15/17.
//
//

import UIKit
import Firebase

class JoinMemberViewController: UIViewController {
    
    var checked = false
    var phone_no = ""
    var store_name = ""
    let ref = FIRDatabase.database().reference(withPath: "membership_users")
    
    @IBAction func CheckBox(_ sender: Any) {
        checked = !checked
    }
    
    @IBAction func YesButton(_ sender: Any) {
        
        if (checked == false) {
            //Show alert if the checkbox is not checked.
            self.showAlert(withMessage: "Please review and check the box for Membership Terms of Services.")
        } else {
            //Register the user by uploading info & initializing on Firebase
            let store_ref = self.ref.child(store_name).child(phone_no)
            let new_member = ["points" : 0,
                              "savings_this_month" : "0.00",
                              "spending_this_month" : "0.00"] as [String : Any]
            store_ref.updateChildValues(new_member)
            
            //After successfully registered, IsMember -> true, MemberLoggedIn = true
            IsMember = true
            MemberLoggedIn = true
            print("IsMember = true")
            print("MemberLoggedIn = true")
            
            //perform segue to the barcode scanner
            performSegue(withIdentifier: "JoinMemberToScanner", sender: self)
        }
    }
    
    @IBAction func NoButton(_ sender: Any) {
        //perform segue to the barcode scanner
        performSegue(withIdentifier: "JoinMemberToScanner", sender: self)
    }

    @IBOutlet weak var YesButton: UIButton!
    @IBOutlet weak var MembershipProgramLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.backgroundColor = UIColor(red:0.53, green:0.05, blue:0.05, alpha:1.0)
        YesButton.layer.cornerRadius = 9

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - show alert
    func showAlert(withMessage: String) {
        let alert = UIAlertController(title: "Eh Oh", message: withMessage, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
