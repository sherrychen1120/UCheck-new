//
//  PaymentMethodViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/4/17.
//
//

import UIKit
import Firebase
import FirebaseAuth

class PaymentMethodViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var ApplePayBorder: UIView!
    @IBOutlet weak var VenmoBorder: UIView!
    @IBOutlet weak var ContinueButton: UIButton!
    
    @IBOutlet weak var CreditCardNoInput: UITextField!
    @IBOutlet weak var CVVInput: UITextField!
    @IBOutlet weak var ExpirationDateInput: UITextField!
    let CreditCardNoLength = 16
    let CVVLength = 3
    
    let ref = FIRDatabase.database().reference(withPath: "user-profiles")
    
    @IBAction func ContinueButton(_ sender: Any) {
        
        let credit_card_no = CreditCardNoInput.text!
        let ex_date = ExpirationDateInput.text!
        let cvv = CVVInput.text!
        
        if (credit_card_no == "" || ex_date == "" || cvv == ""){
            self.showAlert(withMessage: "Incomplete Information")
        } else {
            self.performSegue(withIdentifier: "PaymentToBillingInfo", sender: nil)
        }        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ApplePayBorder.layer.borderWidth = 1.0
        ApplePayBorder.layer.borderColor = UIColor.white.cgColor
        ApplePayBorder.layer.cornerRadius = 9
        
        VenmoBorder.layer.borderWidth = 1.0
        VenmoBorder.layer.borderColor = UIColor.white.cgColor
        VenmoBorder.layer.cornerRadius = 9
        
        ContinueButton.layer.cornerRadius = 9
        
        CreditCardNoInput.delegate = self
        CVVInput.delegate = self
        createNumberPadToolBar()
        
        let expiryDatePicker = MonthYearPickerView()
        ExpirationDateInput.inputView = expiryDatePicker
        expiryDatePicker.onDateSelected = { (month: Int, year: Int) in
            let date = String(format: "%02d/%d", month, year)
            self.ExpirationDateInput.text = date
        }
        
    }
    
    //Function to resign the keyboard after finishing editing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        if textField == CreditCardNoInput {
            return newLength <= CreditCardNoLength // Bool
        } else if textField == CVVInput {
            return newLength <= CVVLength // Bool
        }
        
        return true
        
    }
    
    func createNumberPadToolBar(){
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(PaymentMethodViewController.doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        //setting toolbar as inputAccessoryView
        self.CreditCardNoInput.inputAccessoryView = toolbar
        self.CVVInput.inputAccessoryView = toolbar
        self.ExpirationDateInput.inputAccessoryView = toolbar
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
        if segue.identifier == "PaymentToBillingInfo"{
            
            var uid = ""
            
            if let user = FIRAuth.auth()?.currentUser{
                uid = user.uid
            }
            
            let user_ref = self.ref.child(uid)
            user_ref.updateChildValues([
                "credit_card_no" : CreditCardNoInput.text!,
                "credit_card_ex_date" : ExpirationDateInput.text!,
                "credit_card_cvv" : CVVInput.text!
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
