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
import SafariServices

class CheckOutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var clientToken : String? = nil
    
    @IBAction func ChangePaymentMethodButton(_ sender: Any) {
    }
    
    @IBAction func ConfirmAndPayButton(_ sender: Any) {
        
        if (total == 0.0){
            showAlert(withMessage: "Add something to your shopping cart! :)")
        } else {
            
            //Bring up loading view
            LoadingView.isHidden = false
            ActivityIndicator.isHidden = false
            LoadingText.isHidden = false
            view.bringSubview(toFront: LoadingView)
            LoadingView.bringSubview(toFront: ActivityIndicator)
            LoadingView.bringSubview(toFront: LoadingText)
            ActivityIndicator.startAnimating()
            ActivityIndicator.hidesWhenStopped = true

            self.fetchClientToken(handleComplete: {
                self.createTransaction(completion: {() -> () in
                    //Firebase Ref
                    let ref = FIRDatabase.database().reference(withPath: "shopping_sessions/\(CurrentUserId)")
                    let date = self.getDateTime()
                    
                    
                    let ShoppingSessionID = "s" + CurrentStore + date
                    let sessionRef = ref.child(ShoppingSessionID)
                    
                    //Create the item list JSON
                    var items_bought = [String:Int]()
                    for item in CurrentShoppingCart{
                        let code = item.code
                        items_bought[code] = item.quantity
                    }
                    
                    let total_str = String(format: "%.2f", self.total)
                    
                    //Create the shopping session record JSON
                    let sessionRecord = [
                        "store_id": CurrentStore,
                        "items_bought": items_bought,
                        "total": total_str] as [String : Any]
                    
                    //update the shopping record on Firebase
                    sessionRef.updateChildValues(sessionRecord)
                    
                    DispatchQueue.main.async (execute: { () -> Void in
                        self.ActivityIndicator.stopAnimating()
                        self.performSegue(withIdentifier: "CheckoutToReceipt", sender: self)
                    })
                })
            })
        }
    }
    
    
    private func getDateTime() -> String {
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: Date())
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        // again convert your date to string
        let myStringafd = formatter.string(from: yourDate!)
        
        return(myStringafd)
    }
    
    @IBOutlet weak var ConfirmAndPayButton: UIButton!
    @IBOutlet weak var TotalLabel: UILabel!
    @IBOutlet weak var EstTaxLabel: UILabel!
    @IBOutlet weak var SubtotalLabel: UILabel!
    @IBOutlet weak var ButtonArea: UIView!
    @IBOutlet weak var CartItemsTableView: UITableView!
    @IBOutlet weak var LoadingView: UIView!
    @IBOutlet weak var LoadingText: UILabel!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    
    var total : Double = 0.0
    var tax : Double = 0.0
    
    //var clientToken : String? = nil
    
    @IBAction func BackButton(_ sender: Any) {
        performSegue(withIdentifier: "UnwindToScanner", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Customize the navigation bar
        self.navigationController?.navigationBar.backgroundColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.white,
             NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 19)!]
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        //Customize the button
        ConfirmAndPayButton.layer.cornerRadius = 9
        
        //Shadow of the UIView around the button
        ButtonArea.layer.shadowColor = UIColor.black.cgColor
        ButtonArea.layer.shadowOpacity = 0.3
        ButtonArea.layer.shadowOffset = CGSize(width: 0, height: -5)
        ButtonArea.layer.shadowRadius = 3
        
        //Hide the Loading View
        ActivityIndicator.isHidden = true
        ActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        LoadingView.isHidden = true
        LoadingText.text = "Processing Payment..."
        LoadingText.isHidden = true

        //TableView delegate & data source
        CartItemsTableView.delegate = self
        CartItemsTableView.dataSource = self
        
        //update prices
        updatePrices()
        
    }
    
    func updatePrices(){
        //tax = 0.06 * subtotal
        tax = 0.0
        total = Double(Int((tax + subtotal) * 100)) / 100.0
        SubtotalLabel.text = "Subtotal: $" + String(format: "%.2f", subtotal)
        EstTaxLabel.text = "Tax included"
        //EstTaxLabel.text = "Est. Tax: $" + String(format: "%.2f", tax)
        TotalLabel.text = "Total: $" + String(format: "%.2f", total)
        ShoppingCart.listItems() //for debug
    }
    
    func fetchClientToken(handleComplete:@escaping (()->())) {
        
        if let user = FIRAuth.auth()?.currentUser {
            let uid = user.uid
            CurrentUserId = uid
            
            //Prepare the JSON file
            let json: [String: String] = ["customerId" : uid]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            
            //Attach the JSON file to HTTP request
            let paymentURL = URL(string: "https://us-central1-ucheck-f7c6f.cloudfunctions.net/client_token")!
            var request = URLRequest(url: paymentURL)
            request.httpBody = jsonData
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            //send the HTTP request and catch the response.
            URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
                
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    if let token_received = String(data: data!, encoding: String.Encoding.utf8) {
                        self.clientToken = token_received
                        print("Client token = " + self.clientToken!)
                        handleComplete()
                    }
                }
                
            }.resume()
        } else {
            showAlert(withMessage: "The new user is NULL.")
        }
    }
    
    func createTransaction(completion:@escaping (()->())){
        //create the transaction on the backend
        if let user = FIRAuth.auth()?.currentUser {
            
            let uid = user.uid
            let deviceData = PPDataCollector.collectPayPalDeviceData()
            
            //Prepare the JSON file
            let json: [String: String] = ["amount" : String(self.total),
                                          "customerId" : uid,
                                          "device_data" : deviceData
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
                
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    let responseData = String(data: data!, encoding: String.Encoding.utf8)
                    if (responseData == "Transaction succeeded."){
                        completion()
                    } else {
                        self.showAlert(withMessage: "Transaction problem.")
                    }
                }
                
            }.resume()
            
        } else {
            self.showAlert(withMessage: "Something wrong with fetching the client token.")
        }
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
        cell.ItemName.text = item.item_name
        cell.ItemQuantity.text = "×" + String(item.quantity)
        let item_subtotal = Double(item.item_price)! * Double(item.quantity)
        cell.ItemPrice.text = "$" + String(item_subtotal)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            let curr_item = CurrentShoppingCart[indexPath.row]
            ShoppingCart.deleteItem(oldItem: curr_item)
            self.updatePrices()
            CartItemsTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

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
