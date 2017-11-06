//
//  VenmoSetupViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 11/3/17.
//

import UIKit
import Braintree

class VenmoSetupViewController: UIViewController {
    
    var venmoDriver : BTVenmoDriver?
    var venmoButton : UIButton?
    var apiClient : BTAPIClient!
    var clientToken : String? = nil
    var new_user : User?

    
    @IBOutlet weak var LoadingView: UIView!
    @IBOutlet weak var LoadingText: UILabel!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBAction func VenmoButton(_ sender: Any) {
        //Debug
        print("button clicked")
        
        //Bring up loading view
        LoadingView.isHidden = false
        ActivityIndicator.isHidden = false
        LoadingText.isHidden = false
        view.bringSubview(toFront: LoadingView)
        LoadingView.bringSubview(toFront: ActivityIndicator)
        LoadingView.bringSubview(toFront: LoadingText)
        ActivityIndicator.startAnimating()
        ActivityIndicator.hidesWhenStopped = true
        
        //Fetch the client token for updating customer & payment info
        self.fetchClientToken(handleComplete: {
            //At this point, a client token has already been fetched from Braintree - it has been printed out in the console.
            
            self.apiClient = BTAPIClient(authorization: self.clientToken!)
            self.venmoDriver = BTVenmoDriver(apiClient: self.apiClient)
            
            //Switch to Venmo to get a venmo nonce
            self.venmoDriver?.authorizeAccountAndVault(true, completion: { (venmoAccount, error) in
                //We've never reached this point, since this message is never printed
                print("Venmo Autho method completed.")
                
                guard let venmoAccount = venmoAccount else {
                    print("Error: \(String(describing: error))")
                    return
                }
                // You got a Venmo nonce!
                print("Nonce: " + venmoAccount.nonce)
                
                //Post nonce to server to create a new Venmo user
                self.postNewCustomerNonceToServer(paymentMethodNonce:venmoAccount.nonce, handleComplete: {
                    DispatchQueue.main.async (execute: { () -> Void in
                        self.ActivityIndicator.stopAnimating()
                        self.performSegue(withIdentifier: "VenmoToSelfie", sender: self)
                    })
                })
            })
        
            
        })
    }
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide the Loading View
        ActivityIndicator.isHidden = true
        ActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        LoadingView.isHidden = true
        LoadingText.isHidden = true
        
        // Do any additional setup after loading the view.
    }

    //MARK: - Braintree
    func fetchClientToken(handleComplete:@escaping (()->())) {
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
                    handleComplete()
                }
            }
            
            }.resume()
    }
    
    // Create a new custoemr with payment info and billing address
    func postNewCustomerNonceToServer(paymentMethodNonce: String, handleComplete:@escaping (()->())) {
        //Debug
        print("Posting nonce to server...")
        
        if let new_customer = new_user{
            //Prepare the JSON file
            let json: [String: String] = ["uid" : new_customer.uid,
                                          "first_name" : new_customer.first_name,
                                          "last_name" : new_customer.last_name,
                                          "email" : new_customer.email,
                                          "phone_no" : new_customer.phone_no,
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
                handleComplete()
            }.resume()
            
        } else {
            showAlert(withMessage: "Something wrong with creating the new user.")
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showAlert(withMessage: String) {
        let alert = UIAlertController(title: "Eh Oh", message: withMessage, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
