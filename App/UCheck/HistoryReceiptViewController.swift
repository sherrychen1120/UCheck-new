//
//  HistoryReceiptViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 12/1/17.
//

import UIKit
import Firebase


class HistoryReceiptViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var curr_item : HistorySession? = nil
    var items_bought_lite:[item_lite] = []
    var items_bought:[Item] = []
    var store_id = ""
    var should_reload_list = false
    
    @IBOutlet weak var ReceiptHeaderView: UIView!
    @IBOutlet weak var ItemsTableView: UITableView!
    @IBOutlet weak var TotalLabel: UILabel!
    @IBOutlet weak var StoreLabel: UILabel!
    @IBOutlet weak var DateTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TableView delegate & data source
        ItemsTableView.delegate = self
        ItemsTableView.dataSource = self
        
        //Display the info in the header
        if let session = curr_item {
            store_id = session.store_id
            items_bought_lite = session.items_bought
            
            TotalLabel.text = "Total: $"+session.total
            StoreLabel.text = store_id
            DateTimeLabel.text = formatDateTime(date_time: session.date_time)
        }
        
        //Get a list of bought items
        self.getBoughtItems(handleComplete:{
            DispatchQueue.main.async {
                if (self.should_reload_list){
                    //reload data when the list of items is retrieved
                    self.ItemsTableView.reloadData()
                }
                //Move away the LoadingView
                //self.loadingViewRemove()
            }
        })
    }
    
    //Customize the background of receipt header view in viewDidLayoutSubviews so that the bounds of the view will fit the screen size
    override func viewDidLayoutSubviews() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        ReceiptHeaderView.setGradientBackground(colorOne: Colors.darkRed, colorTwo: Colors.lightRed)
        CATransaction.commit()
    }

    
    @IBAction func BackButton(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToShoppingHistory", sender: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items_bought.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.ItemsTableView.dequeueReusableCell(withIdentifier:"CartItemCell", for: indexPath) as? BigCartItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of BigCartItemTableViewCell.")
        }
        
        let item = items_bought[indexPath.row]
        cell.ItemImage.image = item.item_image
        cell.ItemQuantity.text = "×" + String(item.quantity)
        let item_subtotal = Double(item.item_price)! * Double(item.quantity)
        cell.ItemPrice.text = "$" + String(item_subtotal)
        
        //Database inconsistency: If item is not found in current inventory, show barcode
        let name = item.item_name
        if (name != ""){
            cell.ItemName.text = item.item_name
        } else {
            cell.ItemName.text = item.code
        }
        
        return cell
    }
    
    //get an array of bought items
    func getBoughtItems(handleComplete:@escaping (()->())){
        let ref = FIRDatabase.database().reference(withPath: "inventory/\(store_id)")
        
        //Read objects from Firebase
        ref.observe(.value, with: { snapshot in
            
            //The snapshot contains all the inventory of the store
            let snapshotValue = snapshot.value as! NSDictionary
            let item_numbers = snapshotValue.allKeys as! [String]
            
            //initiate a counter
            var counter = 0
            
            //item_meta contains [item_number:quantity]
            for item_meta in self.items_bought_lite {
                let item_number = item_meta.item_number
                //If we find the item in snapshotValue with the current item_number
                if item_numbers.contains(item_number){
                    let item_dict = snapshotValue[item_number] as! [String:AnyObject]
                    let item = Item(snapshotValue: item_dict, item_number: item_number)
                    self.items_bought.append(item)
                    
                    //retrieve photo for this item
                    self.retrieveItemPhoto(item: item, handleComplete:{
                        //If we have reached the end of items_bought_lite, reload table view
                        counter = counter + 1
                        if (counter == self.items_bought_lite.count){
                            handleComplete()
                        }
                    })
                }
                //if not found, create a dummy item
                else{
                    let item = Item(number: item_number, code: "", name: "Item can't found", price: "0.00", category: "")
                    counter = counter + 1
                    self.items_bought.append(item)
                    if (counter == self.items_bought_lite.count){
                        handleComplete()
                    }
                }
            }
            
            //After all items have been stored, reload list
            self.should_reload_list = true
            handleComplete()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //function to retrieve photo for one item
    let storage = FIRStorage.storage()
    func retrieveItemPhoto(item: Item, handleComplete: @escaping ()->()){
        var code = item.code
        if (code == "-"){
            code = item.item_number
        }
        let storageRef = storage.reference(withPath: "inventory/\(CurrentStore)/\(code).jpg")
        
        storageRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let image = UIImage(data: data!)
                item.addImage(source: image)
                print("Image saved for \(item.item_name)")
            }
            handleComplete()
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

}
