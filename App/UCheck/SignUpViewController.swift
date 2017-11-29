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
import FacebookLogin
import FacebookCore
import FBSDKLoginKit

class SignUpViewController: UIViewController {


    
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
        view.setGradientBackground(colorOne: Colors.darkRed, colorTwo: Colors.lightRed)
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
            
            //Create Firebase account
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
                        //Sign in to Firebase
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
    
    var fb_uid = "";
    @IBAction func FBLoginButton(_ sender: Any) {
        let loginManager = FBSDKLoginManager()
        
        loginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            //get accessToken from fb
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            //swap fb token for firebase token
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            //sign in using firebase token
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                if let user = FIRAuth.auth()?.currentUser{
                    self.fb_uid = user.uid
                    CurrentUserId = user.uid
                    
                    let profile_ref = FIRDatabase.database().reference(withPath: "user-profiles")
                    //Get user name if already exists
                    profile_ref.observeSingleEvent(of:.value, with: { (snapshot) in
                        //bla bla bla
                        self.searchExistingAccounts(snap:snapshot, completion: {
                            self.GraphRequestAndToVenmo()
                        })
                    })
                }
            })//FIRAuth
        }//log in
    }
    
    func searchExistingAccounts(snap: FIRDataSnapshot, completion:@escaping ()->()){
        //is there a faster way to look if user_id exists?
        for item in snap.children {
            let curr_item = item as! FIRDataSnapshot
            let value = curr_item.value as? NSDictionary
            let user_id = value?["uid"] as? String ?? ""
            if (user_id == fb_uid){
                let first_name = value?["first_name"] as? String ?? ""
                let last_name = value?["last_name"] as? String ?? ""
                let email = value?["email"] as? String ?? ""
                let full_name = first_name + " " + last_name
                
                let userData = ["email": email, "full_name": full_name]
                CurrentUserName = full_name
                CurrentUser = email
                
                let defaults = UserDefaults.standard
                defaults.set(userData, forKey: "fb+" + FBSDKAccessToken.current().userID!)
                print("Going into Scanner")
                self.performSegue(withIdentifier: "SignUpToScanner", sender: self)
            }
        }
        completion()
    }
    
    func GraphRequestAndToVenmo(){
        let connection = GraphRequestConnection()
        connection.add(ProfileRequest()) { response, result in
            switch result {
            case .success(let response):
                
                self.new_user = User(uid : self.fb_uid,
                                     first_name : response.first_name!,
                                     last_name : response.last_name!,
                                     email : response.email!,
                                     phone_no : "")
                
                print("User UID: " + self.fb_uid)
                let full_name = response.first_name! + " " + response.last_name!
                
                //update info in the CurrentSession object
                let userData = ["email": response.email!, "full_name": full_name]
                CurrentUser = response.email!
                CurrentUserName = full_name
                
                let defaults = UserDefaults.standard
                defaults.set(userData, forKey: "fb+" + FBSDKAccessToken.current().userID!)
                
                //update info on Firebase
                let user_ref = self.ref.child(self.fb_uid)
                user_ref.setValue(self.new_user.toAnyObject())
                
                //get and add profile picture url to user_ref
                if let pictureUrl = response.profilePictureUrl {
                    user_ref.updateChildValues([
                        "photo_url" : pictureUrl
                    ])
                }
                
                self.performSegue(withIdentifier: "SignUpToVenmo", sender: nil)
            case .failed(let error):
                print("Custom Graph Request Failed: \(error)")
            }
        }
        connection.start()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignUpToVenmo"{
            //Send the new_user to the next VC
            if let nextScene = segue.destination as? VenmoSetupViewController{
                print("User UID: " + self.new_user.uid)
                nextScene.new_user = self.new_user
            }
        } else if segue.identifier == "SignUpToScanner"{
            print("user info stored.")
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
