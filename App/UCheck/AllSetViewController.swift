//
//  AllSetViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 11/8/17.
//

import UIKit

class AllSetViewController: UIViewController {

    
    @IBAction func StartShoppingButton(_ sender: Any) {
        self.performSegue(withIdentifier: "AllSetToScanning", sender: self)
    }
    
    @IBOutlet weak var StartShoppingButton: UIButton!
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
