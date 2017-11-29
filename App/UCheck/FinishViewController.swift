//
//  FinishViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/31/17.
//
//

import UIKit

class FinishViewController: UIViewController {

    @IBAction func BackToHomeButton(_ sender: Any) {
        ShoppingCart.clear()
    }
    @IBOutlet weak var BackToHomeButton: UIButton!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        view.setGradientBackground(colorOne: Colors.darkRed, colorTwo: Colors.lightRed)
        BackToHomeButton.layer.cornerRadius = 9
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
