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

    @IBOutlet weak var SignupButton: UIButton!
    @IBOutlet weak var FBSignupButton: UIButton!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var LoadingText: UILabel!
    @IBOutlet weak var LoadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var LoadingView: UIView!
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
        
        //set gradient
        view.setGradientBackground(colorOne: Colors.darkRed, colorTwo: Colors.lightRed)
        
        //Clean loading view
        loadingViewRemove()
        
        //login button format
        LoginButton.layer.cornerRadius = 4.5
        LoginButton.layer.borderWidth = 1
        LoginButton.layer.borderColor = (UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.75)).cgColor
        
        //signup button and fb button format
        SignupButton.layer.cornerRadius = 4.5
        FBSignupButton.layer.cornerRadius = 4.5
    }

    @IBAction func SignUpButton(_ sender: Any) {
        first_name = FirstNameInput.text!
        last_name = LastNameInput.text!
        email = EmailInput.text!
        password = PasswordInput.text!
        
        //set up loading view
        loadingViewSetup()
        
        if (first_name == "" || last_name == "" || email == "" || password == "" ){
            //Clean loading view
            loadingViewRemove()
            
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
                //Clean loading view
                loadingViewRemove()
                
                self.showAlert(withMessage: "Password requirements unmet.")
            } else {
                //Firebase Auth - create new user
                FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
                    if let error = error {
                        //Clean loading view
                        self.loadingViewRemove()
                        
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
                                //Clean loading view
                                self.loadingViewRemove()
                                
                                print(error?.localizedDescription ?? "FIR signin error")
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
        //set up loading view
        loadingViewSetup()
        
        let loginManager = FBSDKLoginManager()
        
        loginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                //Clean loading view
                self.loadingViewRemove()
                
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            //get accessToken from fb
            guard let accessToken = FBSDKAccessToken.current() else {
                //Clean loading view
                self.loadingViewRemove()
                
                print("Failed to get access token")
                return
            }
            
            //swap fb token for firebase token
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            //sign in using firebase token
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    //Clean loading view
                    self.loadingViewRemove()
                    
                    print("FIR Signin error: \(error.localizedDescription)")
                    self.showAlert(withMessage: "FIR Signin Error.")
                    
                    /*let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)*/
                    
                    //return
                }
                
                if let user = FIRAuth.auth()?.currentUser{
                    self.fb_uid = user.uid
                    CurrentUserId = user.uid
                    
                    let profile_ref = FIRDatabase.database().reference(withPath: "user-profiles")
                    //Get user name if already exists
                    profile_ref.observeSingleEvent(of:.value, with: { (snapshot) in
                        self.searchExistingAccounts(snap:snapshot, completion: {
                            self.GraphRequestAndToVenmo()
                        })
                    })
                }
            })//FIRAuth
        }//log in
    }
    
    func searchExistingAccounts(snap: FIRDataSnapshot, completion:@escaping ()->()){
        //Get all the user ids and search among them
        let snapValue = snap.value as! NSDictionary
        let all_uids = snapValue.allKeys as! [String]
        //If found fb_uid in all profiles, showing that this person has registered before.
        if (all_uids.contains(fb_uid)){
            let value = snapValue[fb_uid] as! NSDictionary
            let first_name = value["first_name"] as? String ?? ""
            let last_name = value["last_name"] as? String ?? ""
            let email = value["email"] as? String ?? ""
            let full_name = first_name + " " + last_name
            
            let userData = ["email": email, "full_name": full_name]
            let defaults = UserDefaults.standard
            defaults.set(userData, forKey: "fb+" + FBSDKAccessToken.current().userID!)
            
            CurrentUserName = full_name
            CurrentUser = email
            
            //download image??
            let storageRef = FIRStorage.storage().reference()
            let imagesRef = storageRef.child("profile_pics")
            let selfieRef = imagesRef.child("\(self.fb_uid).png")
            selfieRef.data(withMaxSize: 1024 * 1024, completion: { (data, error) in
                if (error != nil) {
                    print("Unable to download image")
                } else if (data != nil) {
                    if let image = UIImage(data: data!) {
                        //save photo as the current users image
                        CurrentUserPhoto = image
                        print("image for "+CurrentUserName+" stored.")
                        
                        //store photo in file system for later use
                        saveImage(image: image, path: "profilePicture.png")
                    }
                }
            })
            
            //Going straight to scanner, because this user has signed up and so must already have
            //a linked Venmo account
            print("Going into Scanner")
            self.performSegue(withIdentifier: "SignUpToScanner", sender: self)
        }
        //Otherwise, it's a new FB sign-in
        else{
            completion()
        }
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

                //fb request for profile picture
                let profilePic = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height":300, "width":300, "redirect":false], httpMethod: "GET")
                profilePic?.start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil) {
                        //If the profile pic has been successfully found
                        if let dictionary = result as? [String: Any], let dataDict = dictionary["data"] as? [String: Any], let urlPic = dataDict["url"] as? String {
                            if let imageData = NSData(contentsOf: URL(string: urlPic)!) as Data? {
                                //Create a reference to the profile pics folder
                                let storageRef = FIRStorage.storage().reference()
                                let imagesRef = storageRef.child("profile_pics")
                                
                                // Create a reference to the file you want to upload
                                let selfieRef = imagesRef.child("\(self.fb_uid).png")
                                
                                //store profile pic in firebase storage
                                let metadata = FIRStorageMetadata()
                                metadata.contentType = "image/png"
                                selfieRef.put(imageData, metadata: metadata).observe(.success) { (snapshot) in
                                    let downloadURL = snapshot.metadata?.downloadURL()?.absoluteString
                                    
                                    //put downloadURL in user profile
                                    user_ref.updateChildValues([
                                        "photo_url" : downloadURL
                                    ])
                                }
                                
                                if let image = UIImage(data: imageData) {
                                    //save photo as the current users image
                                    CurrentUserPhoto = image
                                    
                                    //store photo in file system for later use
                                    saveImage(image: image, path: "profilePicture.png")
                                }
                            }
                        }
                    }
                    //profile pic download error
                    else {
                        print("profile pic download error:" + (error?.localizedDescription)!)
                    }
                })
                //perform segue to venmo, without waiting for the procedure to download profile pic
                self.performSegue(withIdentifier: "SignUpToVenmo", sender: nil)
            
            case .failed(let error):
                print("Custom Graph Request Failed: \(error)")
            }
        }
        
        //Start the connection in the end
        connection.start()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignUpToVenmo"{
            //Clean loading view
            //self.loadingViewRemove()
            
            //Send the new_user to the next VC
            if let nextScene = segue.destination as? VenmoSetupViewController{
                print("User UID: " + self.new_user.uid)
                nextScene.new_user = self.new_user
            }
        } else if segue.identifier == "SignUpToScanner"{
            //Clean loading view
            //self.loadingViewRemove()
            
            print("user info stored.")
        }
    }
    
    @IBAction func LoginButton(_ sender: Any) {
        //loading view remove
        self.loadingViewRemove()
        
        self.performSegue(withIdentifier: "SignupToLogin", sender: nil)
    }
    
    
    //functions to set up loading view
    func loadingViewSetup(){
        view.bringSubview(toFront: LoadingView)
        self.LoadingActivityIndicator.isHidden = false
        self.LoadingView.isHidden = false
        self.LoadingText.isHidden = false
        LoadingView.bringSubview(toFront: LoadingActivityIndicator)
        LoadingActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        LoadingView.bringSubview(toFront: LoadingText)
        LoadingText.text = "Signing up..."
        LoadingActivityIndicator.hidesWhenStopped = true
        LoadingActivityIndicator.startAnimating()
    }
    func loadingViewRemove(){
        self.LoadingActivityIndicator.stopAnimating()
        self.LoadingActivityIndicator.isHidden = true
        self.LoadingView.isHidden = true
        self.LoadingText.isHidden = true
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

    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
