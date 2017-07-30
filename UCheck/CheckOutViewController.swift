//
//  CheckOutViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/23/17.
//
//

import UIKit
import BraintreeDropIn
import Braintree

class CheckOutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func ChangePaymentMethodButton(_ sender: Any) {
    }
    @IBAction func ConfirmAndPayButton(_ sender: Any) {
        self.fetchClientToken()
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
        total = tax + subtotal
        MembershipSavedLabel.text = "Membership saving: $" + String(format: "%.2f", total_saving)
        SubtotalLabel.text = "Subtotal: $" + String(format: "%.2f", subtotal)
        EstTaxLabel.text = "Est. Tax: $" + String(format: "%.2f", tax)
        TotalLabel.text = "Total: $" + String(format: "%.2f", total)
        ShoppingCart.listItems() //for debug
    }
    
    func fetchClientToken() {
        let clientTokenURL = NSURL(string: "https://us-central1-ucheck-f7c6f.cloudfunctions.net/client_token")!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            
            if error != nil {
                
                print(error!.localizedDescription)
                
            } else {
                if let clientToken = String(data: data!, encoding: String.Encoding.utf8) {
                    print(clientToken)
                    self.showDropIn(clientTokenOrTokenizationKey: clientToken)
                }
                
                    //TEMP: braintree test client token. just for debug!
                    /*let clientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJjMGY2YTRjYjdlNDljNmQzNjAxZjc0Y2ZmODJjNTYzMjk0MjQ1YTAzOGYwMzFhZDNmMjVjNGVmMTZmNzIwODc3fGNyZWF0ZWRfYXQ9MjAxNy0wNy0yOVQyMDozNTozNy44NjAzNDU4ODcrMDAwMFx1MDAyNm1lcmNoYW50X2lkPTM0OHBrOWNnZjNiZ3l3MmJcdTAwMjZwdWJsaWNfa2V5PTJuMjQ3ZHY4OWJxOXZtcHIiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzLzM0OHBrOWNnZjNiZ3l3MmIvY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tLzM0OHBrOWNnZjNiZ3l3MmIifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6dHJ1ZSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjp0cnVlLCJtZXJjaGFudEFjY291bnRJZCI6ImFjbWV3aWRnZXRzbHRkc2FuZGJveCIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9LCJtZXJjaGFudElkIjoiMzQ4cGs5Y2dmM2JneXcyYiIsInZlbm1vIjoib2ZmIn0="*/
                
            }
            
            // As an example, you may wish to present Drop-in at this point.
            // Continue to the next section to learn more...
        }.resume()
    }
    
    //Function for Braintree drop in
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
                
                self.postNonceToServer(paymentMethodNonce: "fake-valid-visa-nonce")
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }

    //Function for sending payment method nonce
    func postNonceToServer(paymentMethodNonce: String) {
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

    }
    
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
        if item.has_discount {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
