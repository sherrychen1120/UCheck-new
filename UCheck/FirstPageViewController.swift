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
                    }
                    
                    self.ref.child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        // Get user value
                        let value = snapshot.value as? NSDictionary
                        let first_name = value?["first_name"] as? String ?? ""
                        let last_name = value?["last_name"] as? String ?? ""
                        let url_string = value?["photo_url"] as? String ?? ""
                        
                        CurrentUserName = first_name + " " + last_name
                        let photo_url = URL(string: url_string)
                        self.retrievePhoto(url: photo_url!)
                        
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

    private func retrievePhoto(url: URL){
        // Creating a session object with the default configuration.
        let session = URLSession(configuration: .default)
        
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        let downloadPicTask = session.dataTask(with: url) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading user picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded user picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        let image = UIImage(data: imageData)
                        CurrentUserPhoto = image
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        
        downloadPicTask.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
