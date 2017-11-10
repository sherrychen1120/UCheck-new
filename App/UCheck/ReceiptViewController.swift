//
//  ReceiptViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 11/5/17.
//

import UIKit

class ReceiptViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var ButtonArea: UIView!
    @IBOutlet weak var SubtotalLabel: UILabel!
    @IBOutlet weak var TaxLabel: UILabel!
    @IBOutlet weak var TotalLabel: UILabel!
    @IBOutlet weak var ItemsCollection: UICollectionView!
    @IBOutlet weak var ConfirmButton: UIButton!
    @IBAction func ConfirmButton(_ sender: Any) {
        
        performSegue(withIdentifier: "ReceiptToFinish", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Customize the navigation bar
        self.navigationController!.navigationBar.backgroundColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController!.navigationBar.barTintColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.white,
             NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 19)!]
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        //Customize the button
        ConfirmButton.layer.cornerRadius = 9

        //Collection view delegate & data source
        ItemsCollection.delegate = self
        ItemsCollection.dataSource = self
        
        //Shadow of the UIView around the button
        ButtonArea.layer.shadowColor = UIColor.black.cgColor
        ButtonArea.layer.shadowOpacity = 0.3
        ButtonArea.layer.shadowOffset = CGSize(width: 0, height: -5)
        ButtonArea.layer.shadowRadius = 3
        
        //update prices
        updatePrices()
    }
    
    //CollectionView delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CurrentShoppingCart.count
    }
    
    //CollectionView datasource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath as IndexPath) as! ReceiptItemCollectionViewCell
        
        let item = CurrentShoppingCart[indexPath.row]
        cell.ItemImage.image = item.item_image
        cell.ItemQuantity.text = "×" + String(item.quantity)
        cell.ItemName.text = item.item_name
        let item_subtotal = Double(item.item_price)! * Double(item.quantity)
        cell.ItemPrice.text = "$" + String(item_subtotal)
        
        return cell
        
    }
    
    //CollectionView delegate flow layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let itemsPerRow:CGFloat = 2
        let itemsPerColumn:CGFloat = 2
        let hardCodedPadding:CGFloat = 5
        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding - 5
        let itemHeight = (collectionView.bounds.height / itemsPerColumn) - hardCodedPadding - 5
        
        print("itemWidth = " + String(describing: itemWidth))
        print("itemHeight = " + String(describing: itemHeight))
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    var total : Double = 0.0
    var tax : Double = 0.0
    
    func updatePrices(){
        //tax = 0.06 * subtotal
        tax = 0.0
        total = Double(Int((tax + subtotal) * 100)) / 100.0
        SubtotalLabel.text = "Subtotal: $" + String(format: "%.2f", subtotal)
        //TaxLabel.text = "Est. Tax: $" + String(format: "%.2f", tax)
        TaxLabel.text = "Tax included"
        TotalLabel.text = "Total: $" + String(format: "%.2f", total)
        ShoppingCart.listItems() //for debug
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToReceipt(segue: UIStoryboardSegue) {
        //Customize the navigation bar
        self.navigationController!.navigationBar.backgroundColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController!.navigationBar.barTintColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.white,
             NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 19)!]
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        print("unwindSegue to receipt")
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
