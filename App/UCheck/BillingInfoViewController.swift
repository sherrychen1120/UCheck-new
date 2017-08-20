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
import Braintree

class BillingInfoViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var CardholderFirstNameInput: UITextField!
    @IBOutlet weak var CardholderLastNameInput: UITextField!
    @IBOutlet weak var AddressStreetInput: UITextField!
    @IBOutlet weak var AddressExtendedInput: UITextField!
    @IBOutlet weak var AddressCityInput: UITextField!
    @IBOutlet weak var AddressStateInput: UITextField!
    @IBOutlet weak var AddressZipCodeInput: UITextField!
    @IBOutlet weak var ContinueButton: UIButton!
    
    let ref = FIRDatabase.database().reference(withPath: "user-profiles")
    var new_user : User?
    var clientToken : String? = nil
    
    @IBAction func ContinueButton(_ sender: Any) {
        let cardholder_first_name = CardholderFirstNameInput.text!
        let cardholder_last_name = CardholderLastNameInput.text!
        let billing_add_street = AddressStreetInput.text!
        let billing_add_extended = AddressExtendedInput.text!
        let billing_add_city = AddressCityInput.text!
        let billing_add_zip_code = AddressZipCodeInput.text!
        let billing_add_state = AddressStateInput.text!

        if (cardholder_first_name == "" || cardholder_last_name == "" ||
            billing_add_street == "" || billing_add_city == "" ||
            billing_add_zip_code == "" || billing_add_state == "" ){
            self.showAlert(withMessage: "Incomplete Information")
        }else{
            //add billing into to new_user
            new_user?.add_billing_info(cardholder_first_name: cardholder_first_name, cardholder_last_name: cardholder_last_name, billing_add_street: billing_add_street, billing_add_extended: billing_add_extended, billing_add_city: billing_add_city, billing_add_zip_code: billing_add_zip_code, billing_add_state: billing_add_state)
            
            //perform segue to selfie VC
            self.performSegue(withIdentifier: "BillingInfoToSelfie", sender: nil)

        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ContinueButton.layer.cornerRadius = 9
        
        //TextField Delegates...
        CardholderFirstNameInput.delegate = self
        CardholderLastNameInput.delegate = self
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
        
        //Fetch the client token for updating customer & payment info
        self.fetchClientToken()

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

    //MARK: - Braintree
    func fetchClientToken() {
        let clientTokenURL = NSURL(string: "https://us-central1-ucheck-f7c6f.cloudfunctions.net/client_token")!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            
            if error != nil {
                
                print(error!.localizedDescription)
                
            } else {
                if let token_received = String(data: data!, encoding: String.Encoding.utf8) {
                    self.clientToken = token_received
                    print(self.clientToken!)
                }
            }
            
        }.resume()
    }
    
    // Create a new custoemr with payment info and billing address
    func postNewCustomerNonceToServer(paymentMethodNonce: String) {
       
        if let new_customer = new_user{
            //Prepare the JSON file
            let json: [String: String] = ["uid" : new_customer.uid,
                                          "first_name" : new_customer.first_name,
                                          "last_name" : new_customer.last_name,
                                          "email" : new_customer.email,
                                          "phone_no" : new_customer.phone_no,
                                          "cardholder_first_name" : new_customer.cardholder_first_name,
                                          "cardholder_last_name" : new_customer.cardholder_last_name,
                                          "billing_add_street" : new_customer.billing_add_street,
                                          "billing_add_extended" : new_customer.billing_add_extended,
                                          "billing_add_city" : new_customer.billing_add_city,
                                          "billing_add_zip_code" : new_customer.billing_add_zip_code,
                                          "billing_add_state" : new_customer.billing_add_state,
                                          "payment_method_nonce" : paymentMethodNonce
                                          ]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            
            //Attach the JSON file to HTTP request
            let paymentURL = URL(string: "https://us-central1-ucheck-f7c6f.cloudfunctions.net/create_new_customer")!
            var request = URLRequest(url: paymentURL)
            request.httpBody = jsonData
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            //send the HTTP request and catch the response.
            URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                print(data)
            }.resume()

        } else {
            showAlert(withMessage: "Something wrong with creating the new user.")
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BillingInfoToSelfie"{
            
            //Create the card object & create the customer in the Braintree backend
            if let token = clientToken {
             
                //Create the card object
                let braintreeClient = BTAPIClient(authorization: token)!
                let cardClient = BTCardClient(apiClient: braintreeClient)
                if let new_customer = new_user{
                    let card = BTCard(number: new_customer.credit_card_no,
                                      expirationMonth: new_customer.credit_card_ex_month,
                                      expirationYear: new_customer.credit_card_ex_year,
                                      cvv: new_customer.credit_card_cvv)
                    
                    // Communicate the tokenizedCard.nonce to the server & create the new customer.
                    cardClient.tokenizeCard(card) { (tokenizedCard, error) in
                        if (error != nil){
                            print(error?.localizedDescription ?? "error in tokenizing the card.")
                        } else {
                            let tokenized = (tokenizedCard?.nonce)!
                            print(tokenized)
                            self.postNewCustomerNonceToServer(paymentMethodNonce: tokenized)
                        }
                    }
                } else {
                    print("new_user is null.")
                }
                
                
            } else {
                    showAlert(withMessage: "Fetching client token failed.")
            }

        }

    }
    
    func showAlert(withMessage: String) {
        let alert = UIAlertController(title: "Eh Oh", message: withMessage, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    

}
