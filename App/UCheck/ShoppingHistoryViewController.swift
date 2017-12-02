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
    @IBOutlet weak var navBar: UINavigationBar!
    
    var should_reload_list = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Customize navBar
        self.customizeNavBar()
        
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
                    self.HistoryListTableView.reloadData()
                }
                
                //Move away the LoadingView
                self.loadingViewRemove()
            }
        })
    }
    
    func customizeNavBar(){
        navBar.backgroundColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        navBar.barTintColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        navBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.white,
             NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 19)!]
        let navItem = UINavigationItem(title: "Shopping History")
        let backItem = UIBarButtonItem(title: "< Back", style: .plain, target: nil, action: #selector(back))
        backItem.tintColor = UIColor.white
        navItem.leftBarButtonItem = backItem
        navBar.setItems([navItem], animated: false)
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
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
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
        should_reload_list = false
        
        return cell
    }
    
    //tableView func to set cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    //function to format date_time for output in cells
    func formatDateTime(date_time : String) -> String{
        let r1 = date_time.startIndex..<date_time.index(date_time.startIndex, offsetBy: 4)
        let year = String(date_time[r1])
        
        let r2 = date_time.index(date_time.startIndex, offsetBy: 4)..<date_time.index(date_time.startIndex, offsetBy: 6)
        let month = date_time[r2]
        
        let r3 = date_time.index(date_time.startIndex, offsetBy: 6)..<date_time.index(date_time.startIndex, offsetBy: 8)
        let day = date_time[r3]
        
        let r4 = date_time.index(date_time.endIndex, offsetBy: -6)..<date_time.index(date_time.endIndex, offsetBy: -4)
        let hour = date_time[r4]
        
        let r5 = date_time.index(date_time.endIndex, offsetBy: -4)..<date_time.index(date_time.endIndex, offsetBy: -2)
        let minute = date_time[r5]
        
        let date = month + "." + day + "." + year
        let time = hour + ":" + minute
        let display_str = date + " " + time
        return display_str
    }

    
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
