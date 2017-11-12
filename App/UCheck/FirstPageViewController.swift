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
import FacebookLogin
import FacebookCore
import FBSDKLoginKit

class FirstPageViewController: UIViewController {
    
    var uid = ""
    let ref = FIRDatabase.database().reference(withPath: "user-profiles")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //Read from user default. If it's the first time the app is opened on this phone, show the signup page.
        let defaults = UserDefaults.standard
        if let stringOne = defaults.string(forKey: "ExistingDevice") {
            print("Existing Device" + stringOne)
            //print("going to sign up page")
            //self.performSegue(withIdentifier: "FirstPageToSignUp", sender: self)
            
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
                        
                        //Store user id
                        if let user = FIRAuth.auth()?.currentUser{
                            self.uid = user.uid
                            CurrentUserId = user.uid
                        }
                        
                        //Get user name
                        self.ref.child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                            let value = snapshot.value as? NSDictionary
                            let first_name = value?["first_name"] as? String ?? ""
                            let last_name = value?["last_name"] as? String ?? ""
                            //let url_string = value?["photo_url"] as? String ?? ""
                            
                            CurrentUserName = first_name + " " + last_name
                            //self.retrievePhoto(uid : CurrentUserId)
                            print("user info stored.")
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                        
                        self.performSegue(withIdentifier: "FirstPageToScanner", sender: nil)
                    }
                }
            } else if let accessToken = FBSDKAccessToken.current() {
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
                
                FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                    if let error = error {
                        print("Login error: \(error.localizedDescription)")
                        self.performSegue(withIdentifier: "FirstPageToLogin", sender: nil)
                    }
                    
                    //Store user name & photo
                    if let user = FIRAuth.auth()?.currentUser{
                        self.uid = user.uid
                        CurrentUserId = user.uid
                    }
                    
                    //Get user email & names
                    self.ref.child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        let first_name = value?["first_name"] as? String ?? ""
                        let last_name = value?["last_name"] as? String ?? ""
                        let email = value?["email"] as? String ?? ""
                        CurrentUser = email
                        CurrentUserName = first_name + " " + last_name
                        //self.retrievePhoto(uid : CurrentUserId)
                        print("user info stored.")
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                    print("ID BRO:" + (FIRAuth.auth()?.currentUser?.uid)!)
                    self.performSegue(withIdentifier: "FirstPageToScanner", sender: nil)
                    
                })
            } else {
                self.performSegue(withIdentifier: "FirstPageToLogin", sender: nil)
            }
        } else {
            //First time using this device.
            defaults.set("true", forKey: "ExistingDevice")
            print("going to sign up page")
            self.performSegue(withIdentifier: "FirstPageToSignUp", sender: self)
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
