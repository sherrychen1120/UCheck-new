//
//  LoginViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/7/17.
//
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class LoginViewController: UIViewController {
    @IBOutlet weak var EmailInput: UITextField!
    @IBOutlet weak var PasswordInput: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    var uid = ""

    @IBAction func LoginButton(_ sender: Any) {
        
            let email = EmailInput.text!
            let password = PasswordInput.text!
        
            if (email == "" || password == ""){
                showAlert(withMessage: "Incomplete information.")
            } else {
                FIRAuth.auth()!.signIn(withEmail: email, password: password){(user, error) in
                    if error != nil {
                        
                        if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                            
                            switch errCode {
                            case .errorCodeUserNotFound:
                                self.showAlert(withMessage: "User not found")
                            case .errorCodeWrongPassword:
                                self.showAlert(withMessage: "Wrong password")
                            default:
                                self.showAlert(withMessage: "Some error occurs")
                            }
                        }
                        
                    }
                }
                
                let saveEmail: Bool = KeychainWrapper.standard.set(email, forKey: "email")
                let savePassword: Bool = KeychainWrapper.standard.set(password, forKey: "password")
                print("Successfully saved email: \(saveEmail);")
                print("Successfully saved passwordd: \(savePassword).")
                
                CurrentUser = email
                print(CurrentUser + " user stored.")
                self.performSegue(withIdentifier: "LoginToDiscoverNearby", sender: nil)
            }
        
    }
    
    @IBAction func SignUpButton(_ sender: Any) {
        self.performSegue(withIdentifier: "LoginToSetup", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        LoginButton.layer.cornerRadius = 9
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - show alert
    func showAlert(withMessage: String) {
        let alert = UIAlertController(title: "Eh Oh", message: withMessage, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

}
