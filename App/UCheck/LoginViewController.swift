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
import FacebookLogin
import FacebookCore
import FBSDKLoginKit

class LoginViewController: UIViewController {
    @IBOutlet weak var EmailInput: UITextField!
    @IBOutlet weak var PasswordInput: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var FacebookButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var emailSquare: UIView!
    
    var uid = ""
    let ref = FIRDatabase.database().reference(withPath: "user-profiles")

    @IBAction func LoginButton(_ sender: Any) {
        
            let email = EmailInput.text!
            let password = PasswordInput.text!
        
            if (email == "" || password == ""){
                self.showAlert(withMessage: "Incomplete information.")
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
                                self.showAlert(withMessage: "Some other error occurs")
                            }
                        }
                        
                    } else if let curr_user = user {
                        //user != nil
                        
                        let saveEmail: Bool = KeychainWrapper.standard.set(email, forKey: "email")
                        let savePassword: Bool = KeychainWrapper.standard.set(password, forKey: "password")
                        print("Successfully saved email: \(saveEmail);")
                        print("Successfully saved passwordd: \(savePassword).")
                        
                        //Store user email
                        CurrentUser = email
                        print(CurrentUser + " user stored.")
                        
                        self.uid = curr_user.uid
                        print(self.uid)//debug
                        
                        self.ref.child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                            // Get user value
                            let value = snapshot.value as? NSDictionary
                            let first_name = value?["first_name"] as? String ?? ""
                            let last_name = value?["last_name"] as? String ?? ""
                            //let url_string = value?["photo_url"] as? String ?? ""
                            
                            CurrentUserName = first_name + " " + last_name
                            
                            //Save the user info to NSUserDefaults
                            let defaults = UserDefaults.standard
                            if (defaults.object(forKey: "email+" + email) == nil){
                                defaults.set(CurrentUserName, forKey: "email+"+email)
                            }
                            
                            //self.retrievePhoto(url: photo_url!)
                            
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                        
                        self.performSegue(withIdentifier: "LoginToScanner", sender: nil)
                    } else {
                        //user == null
                        self.showAlert(withMessage: "Sign in error. Try again.")
                    }
                }
            }
        
    }
    
    @IBAction func facebookLoginButton(_ sender: Any) {
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
                    self.uid = user.uid
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
    }//function
    
    
    func searchExistingAccounts(snap: FIRDataSnapshot, completion:@escaping ()->()){
        var found = false
        
        //is there a faster way to look if user_id exists?
        //is there no HashMap lookup with firebase?
        for item in snap.children {
            let curr_item = item as! FIRDataSnapshot
            let value = curr_item.value as? NSDictionary
            let user_id = value?["uid"] as? String ?? ""
            if (user_id == uid){
                found = true
                
                let first_name = value?["first_name"] as? String ?? ""
                let last_name = value?["last_name"] as? String ?? ""
                let email = value?["email"] as? String ?? ""
                let full_name = first_name + " " + last_name
                
                let userData = ["email": email, "full_name": full_name]
                CurrentUserName = full_name
                CurrentUser = email
                
                let defaults = UserDefaults.standard
                defaults.set(userData, forKey: "fb+" + FBSDKAccessToken.current().userID!)
                
                break
                
                /*print("Going into Scanner")
                self.performSegue(withIdentifier: "LoginToScanner", sender: self)
                return*/
            }
        }
        
        if (found == true){
            print("Going into Scanner")
            self.performSegue(withIdentifier: "LoginToScanner", sender: self)
        } else {
            completion()
        }
    }
    
    var new_user = User(uid : "", first_name: "", last_name: "", email: "", phone_no: "")
        
    func GraphRequestAndToVenmo(){
        let connection = GraphRequestConnection()
        connection.add(ProfileRequest()) { response, result in
            switch result {
            case .success(let response):
               
                self.new_user = User(uid : self.uid,
                                     first_name : response.first_name!,
                                     last_name : response.last_name!,
                                     email : response.email!,
                                     phone_no : "")
                
                print("User UID: " + self.uid)
                let full_name = response.first_name! + " " + response.last_name!
                
                //update info in the CurrentSession object
                let userData = ["email": response.email!, "full_name": full_name]
                CurrentUser = response.email!
                CurrentUserName = full_name

                let defaults = UserDefaults.standard
                defaults.set(userData, forKey: "fb+" + FBSDKAccessToken.current().userID!)
                
                //update info on Firebase
                let user_ref = self.ref.child(self.uid)
                user_ref.setValue(self.new_user.toAnyObject())
                
                //get and add profile picture url to user_ref
                if let pictureUrl = response.profilePictureUrl {
                    user_ref.updateChildValues([
                        "photo_url" : pictureUrl
                    ])
                }
                
                self.performSegue(withIdentifier: "LoginToVenmo", sender: nil)
            case .failed(let error):
                print("Custom Graph Request Failed: \(error)")
            }
        }
        connection.start()
    }
    
    @IBAction func SignUpButton(_ sender: Any) {
        self.performSegue(withIdentifier: "LoginToSignup", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        LoginButton.roundCorners([.bottomLeft, .bottomRight], radius: 4.5)
        LoginButton.backgroundColor = UIColor(red: 245.0/255.0, green: 117.0/255.0, blue: 117.0/255.0, alpha: 1)
        
        FacebookButton.layer.cornerRadius = 4.5
        FacebookButton.imageView?.contentMode = .scaleAspectFit
        FacebookButton.backgroundColor = UIColor(red: 37.0/255.0, green: 71.0/255.0, blue: 155.0/255.0, alpha: 1)
        
        view.setGradientBackground(colorOne: Colors.darkRed, colorTwo: Colors.lightRed)
        
        signUpButton.layer.cornerRadius = 4.5
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = (UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.75)).cgColor

        let emailImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let userImage = UIImage(named: "usericon")
        emailImageView.image = userImage
        emailImageView.contentMode = .scaleAspectFit
        EmailInput.leftViewMode = .always
        EmailInput.leftView = emailImageView
        
        let passwordImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let lockImage = UIImage(named: "lockicon")
        passwordImageView.image = lockImage
        passwordImageView.contentMode = .scaleAspectFit
        PasswordInput.leftViewMode = .always
        PasswordInput.leftView = passwordImageView
        
        emailSquare.layer.borderWidth = 1
        
        emailSquare.roundCorners([.topLeft, .topRight], radius: 4.5)
        emailSquare.layer.borderColor = (UIColor(red: 195.0/255.0, green: 194.0/255.0, blue: 194.0/255.0, alpha: 1.0)).cgColor

        //Call function to let the keyboard go down when the user taps around
        self.hideKeyboardWhenTappedAround()

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
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - show alert
    func showAlert(withMessage: String) {
        let alert = UIAlertController(title: "Eh Oh", message: withMessage, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginToVenmo"{
            //Send the new_user to the next VC
            if let nextScene = segue.destination as? VenmoSetupViewController{
                print("User UID: " + self.new_user.uid)
                nextScene.new_user = self.new_user
            }
        } else if segue.identifier == "LoginToScanner"{
            print("user info stored.")
        }
    }
}

//To bring down keyboard when a user taps around
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
