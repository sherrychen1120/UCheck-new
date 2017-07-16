//
//  BillingInfoViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/4/17.
//
//

import UIKit
import Firebase
import FirebaseAuth

class BillingInfoViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var CardholderNameInput: UITextField!
    @IBOutlet weak var AddressStreetInput: UITextField!
    @IBOutlet weak var AddressCityInput: UITextField!
    @IBOutlet weak var AddressStateInput: UITextField!
    @IBOutlet weak var AddressZipCodeInput: UITextField!
    @IBOutlet weak var ContinueButton: UIButton!
    
    let ref = FIRDatabase.database().reference(withPath: "user-profiles")
    
    @IBAction func ContinueButton(_ sender: Any) {
        let cardholder_name = CardholderNameInput.text!
        let billing_add_street = AddressStreetInput.text!
        let billing_add_city = AddressCityInput.text!
        let billing_add_zip_code = AddressZipCodeInput.text!
        let billing_add_state = AddressStateInput.text!

        if (cardholder_name == "" || billing_add_street == "" || billing_add_city == "" ||
            billing_add_zip_code == "" || billing_add_state == "" ){
            self.showAlert(withMessage: "Incomplete Information")
        }else{
            self.performSegue(withIdentifier: "BillingInfoToSelfie", sender: nil)

        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ContinueButton.layer.cornerRadius = 9
        
        //TextField Delegates...
        CardholderNameInput.delegate = self
        AddressStreetInput.delegate = self
        AddressCityInput.delegate = self
        AddressZipCodeInput.delegate = self
        //AddressStateInput.delegate = self

        createNumberPadToolBar()
        
        let statePicker = StatePickerView()
        AddressStateInput.inputView = statePicker

        statePicker.onStateSelected = { (selectedState : String) in
            self.AddressStateInput.text = selectedState
            //print("selectedState = " + selectedState)
        }

    }

    //Function to resign the keyboard after finishing editing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = AddressZipCodeInput.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 5 // Bool
    }

    func createNumberPadToolBar(){
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(BillingInfoViewController.doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        //setting toolbar as inputAccessoryView
        self.AddressZipCodeInput.inputAccessoryView = toolbar
        self.AddressStateInput.inputAccessoryView = toolbar

    }
    
    func doneButtonAction() {
        self.view.endEditing(true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BillingInfoToSelfie"{
            
            var uid = ""
            
            if let user = FIRAuth.auth()?.currentUser{
                uid = user.uid
            }
            
            let user_ref = self.ref.child(uid)
            user_ref.updateChildValues([
                "cardholder_name" : CardholderNameInput.text!,
                "billing_add_street" : AddressStreetInput.text!,
                "billing_add_city" : AddressCityInput.text!,
                "billing_add_zip_code" : AddressZipCodeInput.text!,
                "billing_add_state" : AddressStateInput.text!
            ])
        }

    }
    
    func showAlert(withMessage: String) {
        let alert = UIAlertController(title: "Eh Oh", message: withMessage, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    

}
