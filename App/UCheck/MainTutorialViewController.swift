//
//  MainTutorialViewController.swift
//  UCheck
//
//  Created by Ezaan Mangalji on 2017-12-01.
//

import UIKit

class MainTutorialViewController: UIViewController {
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logInButton.layer.cornerRadius = 4.5
        logInButton.layer.borderWidth = 2
        logInButton.layer.borderColor = (Colors.lightRed).cgColor
        
        signUpButton.layer.cornerRadius = 4.5
        signUpButton.backgroundColor = Colors.lightRed
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        self.performSegue(withIdentifier: "tutorialToSignUp", sender: nil)
    }
    
    @IBAction func logInAction(_ sender: Any) {
        self.performSegue(withIdentifier: "tutorialToLogin", sender: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
