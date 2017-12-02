//
//  ShoppingHistoryViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 12/1/17.
//

import UIKit
import Firebase


class ShoppingHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var LoadingView: UIView!
    @IBOutlet weak var LoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var LoadingText: UILabel!
    @IBOutlet weak var HistoryListTableView: UITableView!
    @IBOutlet weak var BackButton: UIBarButtonItem!
    
    var should_reload_list = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TableView delegate & data source
        HistoryListTableView.delegate = self
        HistoryListTableView.dataSource = self
        
        //Loading View setup
        self.loadingViewSetup()
        
        //Get a list of history session objects
        self.getShoppingHistoryItems(handleComplete:{
            DispatchQueue.main.async {
                //Reload data if should_reload_list
                if (self.should_reload_list){
                    self.should_reload_list = false
                    self.HistoryListTableView.reloadData()
                }
                
                //Move away the LoadingView
                self.loadingViewRemove()
            }
        })
    }
    
    @IBAction func BackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadingViewSetup(){
        view.bringSubview(toFront: LoadingView)
        LoadingView.bringSubview(toFront: LoadingIndicator)
        LoadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        LoadingView.bringSubview(toFront: LoadingText)
        LoadingText.text = "Loading..."
        LoadingIndicator.hidesWhenStopped = true
        LoadingIndicator.startAnimating()
    }
    
    func loadingViewRemove(){
        self.LoadingIndicator.stopAnimating()
        self.LoadingView.isHidden = true
        self.LoadingText.isHidden = true
    }
    
    //variable and function to get a list of history shopping sessions
    var history_sessions : [HistorySession] = []
    func getShoppingHistoryItems(handleComplete:@escaping (()->())){
        let uid = CurrentUserId
        let ref = FIRDatabase.database().reference(withPath: "shopping_sessions/\(uid)")
        
        //Read objects from Firebase
        ref.observe(.value, with: { snapshot in
            //Debug: this snapshot contains all the shopping session objects of the user
            print(snapshot)
            
            //If there are at least one history session, store the snapshot in a dictionary
            if !(snapshot.value is NSNull) {
                //Get all the session_ids
                let snapshotValue = snapshot.value as! NSDictionary
                let session_ids = snapshotValue.allKeys as! [String]
                
                //For each session_id, create a HistorySession object and store in the array.
                for session_id in session_ids {
                    let session_dict = snapshotValue[session_id] as! NSDictionary
                    let session = HistorySession(session_id: session_id, dict: session_dict)
                    self.history_sessions.append(session)
                }
                
                //After all sessions have been stored, should reload list.
                self.should_reload_list = true
                handleComplete()
            }
            //If there's no history session
            else {
                //Call completion handler directly (remove the loading view)
                handleComplete()
            }
            
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history_sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //create cell instance as shoppingHistoryItem
        guard let cell = self.HistoryListTableView.dequeueReusableCell(withIdentifier:"HistorySessionCell", for: indexPath) as? HistorySessionTableViewCell else {
            fatalError("The dequeued cell is not an instance of HistorySessionTableViewCell.")
        }
        
        //Fill in the contents of the cell.
        let session = history_sessions[indexPath.row]
        cell.StoreLabel.text = session.store_id
        cell.TotalPriceLabel.text = "$" + session.total
        cell.DateTimeLabel.text = formatDateTime(date_time: session.date_time)
        
        
        return cell
    }
    
    //tableView func to set cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    //tableView func for cell selection
    var selected_item : HistorySession? = nil
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected_item = history_sessions[indexPath.row]
        self.performSegue(withIdentifier: "ShoppingHistoryToHistoryReceipt", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //If directing to history receipt, pass on the selected session
        if (segue.identifier == "ShoppingHistoryToHistoryReceipt"){
            let controller = segue.destination as! HistoryReceiptViewController
            controller.curr_item = selected_item
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let row = HistoryListTableView.indexPathForSelectedRow {
            self.HistoryListTableView.deselectRow(at: row, animated: false)
        }
    }
    
    @IBAction func unwindToShoppingHistory(segue: UIStoryboardSegue) {
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    


}
