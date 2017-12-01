//
//  MenuViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/20/17.
//
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import SafariServices
import FBSDKLoginKit

class MenuViewController: UIViewController, SFSafariViewControllerDelegate {

    var uid : String = ""
    var delegate: communicationScanner? = nil
    var loggingOut = false
    
    @IBAction func HelpButton(_ sender: Any) {
        forHelp = true
        print("forHelp = " + String(forHelp))
        if (forHelp == true){
            forHelp = false
            self.dismiss(animated: true, completion: nil)
            self.delegate?.showHelpForm()
        } else {
            self.dismiss(animated: true, completion: nil)
            self.delegate?.scannerSetup()
        }
    }
    
    @IBAction func LogoutButton(_ sender: Any) {
        print("LogoutButton clicked")
        loggingOut = true
        
        //Identify login method and log out
        //If logged in through FB
        if let access_token = FBSDKAccessToken.current(){
            //Log out and then dismiss Menu VC
            logoutProcedure(EmailOrFB: "FB", removeUserDefaultsForKey: "fb+" + access_token.userID, deleteProfilePic: true, cleanCurrentSession: true, cleanShoppingCart: true, handleComplete: {
                    self.dismiss(animated: true, completion: nil)
                })
        }
        //If logged in through email
        else {
            //Log out and then dismiss Menu VC
            logoutProcedure(EmailOrFB: "Email", removeUserDefaultsForKey: "email+" + CurrentUser, deleteProfilePic: true, cleanCurrentSession: true, cleanShoppingCart: true, handleComplete: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    @IBOutlet weak var UserImage: UIImageView!
    @IBOutlet weak var UserNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setGradientBackground(colorOne: Colors.darkRed, colorTwo: Colors.lightRed)
        
        //set the user's photo in the menu
        if CurrentUserPhoto != nil {
            UserImage.image = CurrentUserPhoto
        }
        UserNameLabel.text = CurrentUserName
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("menu view will disappear")
        if (loggingOut == false){
            self.delegate?.scannerSetup()
        } else {
            loggingOut = false
            self.delegate?.toLogOut()
        }
    }
    
    func showHelpform() {
        let urlString = "https://docs.google.com/forms/d/e/1FAIpQLSfO1WsJ23ByoqNSsgqGotFY4s7NKh6UEehAuV9tygDwUcFEyQ/viewform?usp=sf_link"
        
        if let url = URL(string: urlString) {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("safariVCDidFinish Called.")
        self.performSegue(withIdentifier: "unwindToScanner", sender: nil)
        //controller.dismiss(animated: true, completion: nil)
        //self.dismiss(animated: true, completion: nil)
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
