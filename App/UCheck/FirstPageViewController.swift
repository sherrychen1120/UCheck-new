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
