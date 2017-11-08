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
    let ref = FIRDatabase.database().reference(withPath: "user-profiles")

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
                    
                    let saveEmail: Bool = KeychainWrapper.standard.set(email, forKey: "email")
                    let savePassword: Bool = KeychainWrapper.standard.set(password, forKey: "password")
                    print("Successfully saved email: \(saveEmail);")
                    print("Successfully saved passwordd: \(savePassword).")
                    
                    //Store user email
                    CurrentUser = email
                    print(CurrentUser + " user stored.")

                    self.uid = (user?.uid)!
                    print(self.uid)
                    
                    self.performSegue(withIdentifier: "LoginToScanner", sender: nil)
                }
                
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
    
    // MARK: - show alert
    func showAlert(withMessage: String) {
        let alert = UIAlertController(title: "Eh Oh", message: withMessage, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            self.ref.child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let first_name = value?["first_name"] as? String ?? ""
                let last_name = value?["last_name"] as? String ?? ""
                let url_string = value?["photo_url"] as? String ?? ""
                
                CurrentUserName = first_name + " " + last_name
                //let photo_url = URL(string: url_string)
                //self.retrievePhoto(url: photo_url!)
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
            print("user info stored.")

    }
}
