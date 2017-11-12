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
    var uid = ""
    let ref = FIRDatabase.database().reference(withPath: "user-profiles")

    @IBAction func LoginButton(_ sender: Any) {
        
            let email = EmailInput.text!
            let password = PasswordInput.text!
        
//            if (email == "" || password == ""){
//                showAlert(withMessage: "Incomplete information.")
//            } else {
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
                    
                    self.ref.child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        // Get user value
                        let value = snapshot.value as? NSDictionary
                        let first_name = value?["first_name"] as? String ?? ""
                        let last_name = value?["last_name"] as? String ?? ""
                        //let url_string = value?["photo_url"] as? String ?? ""
                        
                        CurrentUserName = first_name + " " + last_name
                        //self.retrievePhoto(url: photo_url!)
                        
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                    self.performSegue(withIdentifier: "LoginToScanner", sender: nil)
//                }
                
            }
        
    }
    
    struct MyProfileRequest: GraphRequestProtocol {
        struct Response: GraphResponseProtocol {
            var first_name: String?
            var last_name: String?
            var id: String?
            var email: String?
            var profilePictureUrl: String?
            
            init(rawResponse: Any?) {
                // Decode JSON from rawResponse into other properties here.
                guard let response = rawResponse as? Dictionary<String, Any> else {
                    return
                }
                
                if let first_name = response["first_name"] as? String {
                    self.first_name = first_name
                }
                
                if let last_name = response["last_name"] as? String {
                    self.last_name = last_name
                }
                
                if let id = response["id"] as? String {
                    self.id = id
                }
                
                if let email = response["email"] as? String {
                    self.email = email
                }
                
                if let picture = response["picture"] as? Dictionary<String, Any> {
                    
                    if let data = picture["data"] as? Dictionary<String, Any> {
                        if let url = data["url"] as? String {
                            self.profilePictureUrl = url
                        }
                    }
                }
            }
        }
        
        var graphPath = "/me"
        var parameters: [String : Any]? = ["fields": "id, first_name, last_name, email, picture"]
        var accessToken = AccessToken.current
        var httpMethod: GraphRequestHTTPMethod = .GET
        var apiVersion: GraphAPIVersion = .defaultVersion
    }
    
    var new_user = User(uid : "", first_name: "", last_name: "", email: "", phone_no: "")
    
    @IBAction func facebookLoginButton(_ sender: Any) {
        let loginManager = FBSDKLoginManager()
        
        loginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)

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
        for item in snap.children {
            let curr_item = item as! FIRDataSnapshot
            let value = curr_item.value as? NSDictionary
            let user_id = value?["uid"] as? String ?? ""
            if (user_id == uid){
                let first_name = value?["first_name"] as? String ?? ""
                let last_name = value?["last_name"] as? String ?? ""
                let email = value?["email"] as? String ?? ""
                CurrentUserName = first_name + " " + last_name
                CurrentUser = email
                print("Going into Scanner")
                self.performSegue(withIdentifier: "LoginToScanner", sender: self)
            }
        }
        completion()
    }
        
    func GraphRequestAndToVenmo(){
        let connection = GraphRequestConnection()
        connection.add(MyProfileRequest()) { response, result in
            switch result {
            case .success(let response):
                
                self.new_user = User(uid : self.uid,
                                     first_name : response.first_name!,
                                     last_name : response.last_name!,
                                     email : response.email!,
                                     phone_no : "")
                
                print("UID1: " + self.uid)
                
                //update info on Firebase
                let user_ref = self.ref.child(self.uid)
                user_ref.setValue(self.new_user.toAnyObject())
                
                //update info in the CurrentSession object
                CurrentUser = response.email!
                CurrentUserName = response.first_name! + " " + response.last_name!
                
                self.performSegue(withIdentifier: "LoginToVenmo", sender: nil)
            case .failed(let error):
                print("Custom Graph Request Failed: \(error)")
            }
        }
        connection.start()
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
                print("UID2: " + self.new_user.uid)
                nextScene.new_user = self.new_user
            }
        } else if segue.identifier == "LoginToScanner"{
            
            print("user info stored.")
        }
    }
}
