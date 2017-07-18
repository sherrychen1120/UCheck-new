//
//  ItemDetailViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/17/17.
//
//

import UIKit

class ItemDetailViewController: UIViewController, HalfModalPresentable {

    //take the item code from the last VC and create an object with the JSON
    var current_item = ""
    
    @IBOutlet weak var ItemNameLabel: UILabel!
    @IBOutlet weak var ItemPriceLabel: UILabel!
    @IBOutlet weak var ItemImage: UIImageView!
    
    @IBAction func CancelButton(_ sender: Any) {
        if let delegate = transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        performSegue(withIdentifier: "ItemDetailToScanning", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
