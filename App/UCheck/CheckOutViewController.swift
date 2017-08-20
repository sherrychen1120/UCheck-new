//
//  CheckOutViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/23/17.
//
//

import UIKit
import Firebase
import Braintree

class CheckOutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func ChangePaymentMethodButton(_ sender: Any) {
    }
    
    @IBAction func ConfirmAndPayButton(_ sender: Any) {
        self.finishPayment{ () -> () in
            DispatchQueue.main.async (execute: { () -> Void in
                self.performSegue(withIdentifier: "CheckOutToFinish", sender: self)
            })
        }
    }
    
    @IBOutlet weak var ConfirmAndPayButton: UIButton!
    @IBOutlet weak var TotalLabel: UILabel!
    @IBOutlet weak var EstTaxLabel: UILabel!
    @IBOutlet weak var SubtotalLabel: UILabel!
    @IBOutlet weak var MembershipSavedLabel: UILabel!
    @IBOutlet weak var ButtonArea: UIView!
    @IBOutlet weak var CartItemsTableView: UITableView!
    
    var total : Double = 0.0
    var tax : Double = 0.0
    
    //var clientToken : String? = nil
    
    @IBAction func BackButton(_ sender: Any) {
        performSegue(withIdentifier: "UnwindToScanner", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Customize the navigation bar
        self.navigationController!.navigationBar.backgroundColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController!.navigationBar.barTintColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController!.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 19)!]
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        //Customize the button
        ConfirmAndPayButton.layer.cornerRadius = 9
        
        //Shadow of the UIView around the button
        ButtonArea.layer.shadowColor = UIColor.black.cgColor
        ButtonArea.layer.shadowOpacity = 0.3
        ButtonArea.layer.shadowOffset = CGSize(width: 0, height: -5)
        ButtonArea.layer.shadowRadius = 3

        //TableView delegate & data source
        CartItemsTableView.delegate = self
        CartItemsTableView.dataSource = self
        
        //update prices
        updatePrices()
        
    }
    
    func updatePrices(){
        tax = 0.06 * subtotal
        total = Double(Int((tax + subtotal) * 100)) / 100.0
        MembershipSavedLabel.text = "Membership saving: $" + String(format: "%.2f", total_saving)
        SubtotalLabel.text = "Subtotal: $" + String(format: "%.2f", subtotal)
        EstTaxLabel.text = "Est. Tax: $" + String(format: "%.2f", tax)
        TotalLabel.text = "Total: $" + String(format: "%.2f", total)
        ShoppingCart.listItems() //for debug
    }
    
    //MARK: - Braintree
    func finishPayment(handleComplete:@escaping (()->())) {
        //First fetch the client token.
        let clientTokenURL = NSURL(string: "https://us-central1-ucheck-f7c6f.cloudfunctions.net/client_token")!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            
            if error != nil {
                
                print(error!.localizedDescription)
                
            } else {
                if let token_received = String(data: data!, encoding: String.Encoding.utf8) {
                    //after getting the client token
                    print("Client token successfully fetched.")
                    print(token_received)
                    
                    //create the transaction on the backend
                    if let user = FIRAuth.auth()?.currentUser {
                        
                        let uid = user.uid
                        
                        //Prepare the JSON file
                        let json: [String: String] = ["amount" : String(self.total),
                                                      "customerId" : uid
                        ]
                        let jsonData = try? JSONSerialization.data(withJSONObject: json)
                        
                        //Attach the JSON file to HTTP request
                        let paymentURL = URL(string: "https://us-central1-ucheck-f7c6f.cloudfunctions.net/create_new_transaction")!
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
                            
                            let responseData = String(data: data, encoding: String.Encoding.utf8)
                            
                            if (responseData == "Transaction succeeded."){
                                handleComplete()
                            } else {
                                self.showAlert(withMessage: "Transaction problem.")
                            }
                            
                        }.resume()
                        
                    } else {
                        self.showAlert(withMessage: "Something wrong with fetching the client token.")
                    }

                }
            }
            
            }.resume()
    }
    
    //Function for sending payment method nonce
    /*func postNonceToServer(paymentMethodNonce: String) {
        // Update URL with your server
        let paymentURL = URL(string: "https://us-central1-ucheck-f7c6f.cloudfunctions.net/payment_method")!
        var request = URLRequest(url: paymentURL)
        let totalString = String(total)
        let dictionary = ["payment_method_nonce": "\(paymentMethodNonce)",
                          "amount": "\(totalString)"]
        
        //converting the dictionary to JSON
        let jsonData = try? JSONSerialization.data(withJSONObject: dictionary)
        print(jsonData)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            } else if let resultSuccess = String(data: data!, encoding: String.Encoding.utf8) {
                print(resultSuccess)
            }
        }.resume()

    }*/
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CurrentShoppingCart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.CartItemsTableView.dequeueReusableCell(withIdentifier:"CartItemCell", for: indexPath) as? BigCartItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of BigCartItemTableViewCell.")
        }
        
        let item = CurrentShoppingCart[indexPath.row]
        cell.ItemImage.image = item.item_image
        cell.ItemName.text = item.name
        cell.ItemQuantity.text = "×" + String(item.quantity)
        if (item.has_itemwise_discount != "none") {
            let item_subtotal = Double(item.discount_price)! * Double(item.quantity)
            cell.ItemPrice.text = "$" + String(item_subtotal)
        } else {
            let item_original_subtotal = Double(item.price)! * Double(item.quantity)
            cell.ItemPrice.text = "$" + String(item_original_subtotal)
        }
        
        return cell
    }
    
    /*func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = CurrentShoppingCart[indexPath.row]
            ShoppingCart.deleteItem(oldItem: item)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            updatePrices()
        }
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(withMessage: String) {
        let alert = UIAlertController(title: "Eh Oh", message: withMessage, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

}
