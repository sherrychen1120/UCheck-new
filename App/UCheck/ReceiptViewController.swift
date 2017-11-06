//
//  ReceiptViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 11/5/17.
//

import UIKit

class ReceiptViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 19)!]
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        //Customize the button
        ConfirmButton.layer.cornerRadius = 9

        //Collection view delegate & data source
        ItemsCollection.delegate = self
        ItemsCollection.dataSource = self
    }
    
    //CollectionView delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    //CollectionView datasource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath as IndexPath) as! ReceiptItemCollectionViewCell
        
        let item = CurrentShoppingCart[indexPath.row]
        cell.ItemImage.image = item.item_image
        cell.ItemName.text = item.name
        if (item.has_itemwise_discount != "none") {
            let item_subtotal = Double(item.discount_price)! * Double(item.quantity)
            cell.ItemPrice.text = "$" + String(item_subtotal)
        } else {
            let item_original_subtotal = Double(item.price)! * Double(item.quantity)
            cell.ItemPrice.text = "$" + String(item_original_subtotal)
        }
        
        return cell
        
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
