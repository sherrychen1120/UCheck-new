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
    
    var uid = ""
    let ref = FIRDatabase.database().reference(withPath: "user-profiles")
    
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
                    //Store user email
                    CurrentUser = email
                    
                    //Store user name & photo
                    if let user = FIRAuth.auth()?.currentUser{
                        self.uid = user.uid
                        CurrentUserId = user.uid
                    }
                    
                    self.ref.child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        // Get user value
                        let value = snapshot.value as? NSDictionary
                        let first_name = value?["first_name"] as? String ?? ""
                        let last_name = value?["last_name"] as? String ?? ""
                        let url_string = value?["photo_url"] as? String ?? ""
                        
                        CurrentUserName = first_name + " " + last_name
                        self.retrievePhoto(uid : CurrentUserId)
                        print("user info stored.")
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                    self.performSegue(withIdentifier: "FirstPageToDiscoverNearby", sender: nil)
                }
            }
        } else {
            self.performSegue(withIdentifier: "FirstPageToLogin", sender: nil)
        }
        

    }

    private func retrievePhoto(uid: String){
        
        let image_ref = FIRStorage.storage().reference(withPath:"profile_pics/\(uid).png")
        
        image_ref.data(withMaxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let image = UIImage(data: data!)
                print("Downloaded user picture")
                CurrentUserPhoto = image
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
