//
//  FindStoreTipViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/13/17.
//
//

import UIKit

class FindStoreTipViewController: UIViewController {

    @IBAction func BackButton(_ sender: Any) {
        performSegue(withIdentifier: "UnwindToDiscoverNearby", sender: nil)
    }
    
    @IBOutlet weak var QRCodeExampleImage: UIImageView!
    @IBOutlet weak var FoundItButton: UIButton!
    
    @IBAction func FoundItButton(_ sender: Any) {
        performSegue(withIdentifier: "FindStoreTipToScanStoreCode", sender: nil)
    }
    
    override func viewDidLoad() {
        //initialization
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.backgroundColor = UIColor(red:0.53, green:0.05, blue:0.05, alpha:1.0)

        FoundItButton.layer.cornerRadius = 9
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
