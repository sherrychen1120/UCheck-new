//
//  AllSetViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/4/17.
//
//

import UIKit

class AllSetViewController: UIViewController {

    @IBOutlet weak var DiscoverNearbyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DiscoverNearbyButton.layer.cornerRadius = 9
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
