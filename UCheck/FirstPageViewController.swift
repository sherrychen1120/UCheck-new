//
//  FirstPageViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/2/17.
//
//

import UIKit
import Firebase
import SwiftKeychainWrapper


class FirstPageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        let retrievedEmail: String? = KeychainWrapper.standard.string(forKey: "email")
        let retrievedPassword: String? = KeychainWrapper.standard.string(forKey: "password")
        
        if let email = retrievedEmail, let password = retrievedPassword{
            FIRAuth.auth()!.signIn(withEmail: email, password: password){
                (user, error) in
                if error != nil {
                    self.performSegue(withIdentifier: "FirstPageToLogin", sender: nil)
                } else {
                    CurrentUser = email
                    self.performSegue(withIdentifier: "FirstPageToDiscoverNearby", sender: nil)
                }
            }
        } else {
            self.performSegue(withIdentifier: "FirstPageToLogin", sender: nil)
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
