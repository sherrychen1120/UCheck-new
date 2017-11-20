//
//  SignUpViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 11/12/17.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftKeychainWrapper

class SignUpViewController: UIViewController {

    @IBAction func FBLoginButton(_ sender: Any) {
        
    }
    
    @IBOutlet weak var FirstNameInput: UITextField!
    @IBOutlet weak var LastNameInput: UITextField!
    @IBOutlet weak var EmailInput: UITextField!
    @IBOutlet weak var PasswordInput: UITextField!
    
    let ref = FIRDatabase.database().reference(withPath: "user-profiles")
    var new_user = User(uid : "", first_name: "", last_name: "", email: "", phone_no: "")
    var first_name = ""
    var last_name = ""
    var email = ""
    var password = ""
    var signUpSuccess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func SignUpButton(_ sender: Any) {
        first_name = FirstNameInput.text!
        last_name = LastNameInput.text!
        email = EmailInput.text!
        password = PasswordInput.text!
        
        if (first_name == "" || last_name == "" || email == "" || password == "" ){
            self.showAlert(withMessage: "Incomplete Information")
        } else {
            //password validation regEx
            var isValidPassword: Bool {
                do {
                    let regex = try NSRegularExpression(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d$@$!%*#?&]{6,18}$")
                    if(regex.firstMatch(in: password, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, password.count)) != nil){
                        
                        if(password.count>=6 && password.count<=18){
                            return true
                        }else{
                            return false
                        }
                    }else{
                        return false
                    }
                } catch {
                    return false
                }
            }
            
            print("isValidPassword = " + String(isValidPassword))
            
            if (!isValidPassword){
                self.showAlert(withMessage: "Password requirements unmet.")
            } else {
                //Firebase Auth - create new user
                FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        
                        if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                            
                            switch errCode {
                            case .errorCodeInvalidEmail:
                                self.showAlert(withMessage: "Invalid email.")
                            case .errorCodeEmailAlreadyInUse:
                                self.showAlert(withMessage: "Email already in use.")
                            case .errorCodeWeakPassword:
                                self.showAlert(withMessage: "Password should contain at least 6 characters.")
                            default:
                                print("Create User Error: \(error)")
                            }
                        }
                        
                    } else {
                        FIRAuth.auth()!.signIn(withEmail: self.email, password: self.password){(user, error) in
                            
                            if (error != nil){
                                print(error?.localizedDescription)
                            } else {
                                //fill the info to the new_user object
                                var uid = ""
                                if let user = FIRAuth.auth()?.currentUser{
                                    uid = user.uid
                                    CurrentUserId = user.uid
                                }
                                self.new_user = User(uid : uid,
                                                     first_name : self.first_name,
                                                     last_name : self.last_name,
                                                     email : self.email,
                                                     phone_no : "")
                                
                                //update info on Firebase
                                let user_ref = self.ref.child(uid)
                                user_ref.setValue(self.new_user.toAnyObject())
                                
                                //update info in the CurrentSession object
                                CurrentUser = self.email
                                CurrentUserName = self.first_name + " " + self.last_name
                                
                                //Save the user info to NSUserDefaults
                                let defaults = UserDefaults.standard
                                if (defaults.object(forKey: self.email) == nil){
                                    defaults.set(CurrentUserName, forKey: "email+"+self.email)
                                }
                                
                                let saveEmail: Bool = KeychainWrapper.standard.set(self.email, forKey: "email")
                                let savePassword: Bool = KeychainWrapper.standard.set(self.password, forKey: "password")
                                
                                print("Successfully saved email: \(saveEmail);")
                                print("Successfully saved passwordd: \(savePassword).")
                                
                                self.performSegue(withIdentifier: "SignUpToVenmo", sender: nil)
                                
                            }
                            
                        }
                        
                    }//If
                }//FIRAutho
            }
            
        }
    }
    
    /*func isPasswordValid(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@","^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]){6,}$")
        return passwordTest.evaluate(with: password)
    }*/
    
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
        
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
