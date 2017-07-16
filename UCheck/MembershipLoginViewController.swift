//
//  MembershipLoginViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/15/17.
//
//

import UIKit

class MembershipLoginViewController: UIViewController {
    
    
    @IBOutlet weak var MembershipProgramLabel: UILabel!
    @IBOutlet weak var YesButton: UIButton!
    @IBAction func YesButton(_ sender: Any) {
        MemberLoggedIn = true
        //segue to barcode scanner
    }
    @IBAction func NoButton(_ sender: Any) {
        //segue to barcode scanner
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.backgroundColor = UIColor(red:0.53, green:0.05, blue:0.05, alpha:1.0)
        YesButton.layer.cornerRadius = 9
        
        //Read the name of the membership program from Firebase
        //MembershipProgramLabel.text = ...
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
