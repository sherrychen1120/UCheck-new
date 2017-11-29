//
//  AllSetViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 11/8/17.
//

import UIKit

class AllSetViewController: UIViewController {

    @IBOutlet weak var StartShoppingButton: UIButton!

    @IBAction func StartShoppingButton(_ sender: Any) {
        self.performSegue(withIdentifier: "AllSetToScanning", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.setGradientBackground(colorOne: Colors.darkRed, colorTwo: Colors.lightRed)
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
