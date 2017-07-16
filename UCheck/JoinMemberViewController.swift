//
//  JoinMemberViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/15/17.
//
//

import UIKit

class JoinMemberViewController: UIViewController {
    
    @IBAction func YesButton(_ sender: Any) {
        
        //perform segue to the register VC
        //After successfully registered, IsMember -> true, MemberLoggedIn = true
    }
    @IBAction func NoButton(_ sender: Any) {
        //perform segue to the barcode scanner
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
}
