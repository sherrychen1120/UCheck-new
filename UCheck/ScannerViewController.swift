//
//  ScannerViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/15/17.
//
//

import UIKit

class ScannerViewController: UIViewController {

    @IBOutlet weak var ScanningArea: UIView!
    @IBOutlet weak var CheckoutButton: UIButton!
    @IBAction func CheckoutButton(_ sender: Any) {
    }
    @IBOutlet weak var RecommendationCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Fix the navigation bar - let it show up
        
        CheckoutButton.layer.cornerRadius = 9

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
