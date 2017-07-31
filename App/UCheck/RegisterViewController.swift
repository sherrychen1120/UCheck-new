//
//  RegisterViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/2/17.
//
//

import UIKit
import Firebase
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate {
    //Text Input Outlets
    
    @IBOutlet weak var FirstNameInput: UITextField!
    @IBOutlet weak var LastNameInput: UITextField!
    @IBOutlet weak var EmailInput: UITextField!
    @IBOutlet weak var PhoneNoInput: UITextField!
    @IBOutlet weak var PasswordInput: UITextField!
    
    let PhoneNoLength = 10
    var first_name = ""
    var last_name = ""
    var email = ""
    var phone_no = ""
    var password = ""
    var checked = false
    var signUpSuccess = false
    
    let ref = FIRDatabase.database().reference(withPath: "user-profiles")
    
    var new_user = User(uid : "", first_name: "", last_name: "", email: "", phone_no: "")
    
    //Register Button Outlets & Actions
    @IBOutlet weak var RegisterButton: UIButton!
    
    @IBAction func CheckBox(_ sender: Any) {
        checked = !checked
    }
    
    @IBAction func RegisterButton(_ sender: Any) {
        
        first_name = FirstNameInput.text!
        last_name = LastNameInput.text!
        email = EmailInput.text!
        phone_no = PhoneNoInput.text!
        password = PasswordInput.text!
        
        if (first_name == "" || last_name == "" || email == "" || phone_no == "" || password == "" ){
            self.showAlert(withMessage: "Incomplete Information")
        } else if (checked == false){
            self.showAlert(withMessage: "Please review and check the box for Terms of Services.")
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
                            }
                            self.new_user = User(uid : uid,
                                                 first_name : self.first_name,
                                                 last_name : self.last_name,
                                                 email : self.email,
                                                 phone_no : self.phone_no)
                            
                            //update info on Firebase
                            let user_ref = self.ref.child(uid)
                            user_ref.setValue(self.new_user.toAnyObject())
                            
                            //update info in the CurrentUser object
                            CurrentUser = self.email
                            CurrentUserName = self.first_name + " " + self.last_name
                            
                            self.performSegue(withIdentifier: "RegisterToPayment", sender: nil)

                        }
                        
                    }
                    
                }
            }
            
        }
    }
    
    override func viewDidLoad() {
        //Initialization
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.backgroundColor = UIColor(red:0.53, green:0.05, blue:0.05, alpha:1.0)
        RegisterButton.layer.cornerRadius = 9
        
        //Input TextFields delegate
        PhoneNoInput.delegate = self
        
        PasswordInput.isSecureTextEntry = true
        
        //Number Pad 'Done' Button setup
        createNumberPadToolBar()
        
    }
    
    //MARK: - limit phone no. length
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = PhoneNoInput.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= PhoneNoLength
    }
    
    //MARK: - create Done tool bar
    func createNumberPadToolBar(){
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(RegisterViewController.doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        //setting toolbar as inputAccessoryView
        self.FirstNameInput.inputAccessoryView = toolbar
        self.LastNameInput.inputAccessoryView = toolbar
        self.EmailInput.inputAccessoryView = toolbar
        self.PhoneNoInput.inputAccessoryView = toolbar
        self.PasswordInput.inputAccessoryView = toolbar
    }
    
    func doneButtonAction() {
        self.view.endEditing(true)
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

    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RegisterToPayment"{
            //Send the new_user to the next VC
            if let nextScene = segue.destination as? PaymentMethodViewController{
                nextScene.new_user = self.new_user
            }
        }
    }
    

}
