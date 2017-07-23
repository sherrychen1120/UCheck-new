//
//  MenuViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/20/17.
//
//

import UIKit
import Firebase

class MenuViewController: UIViewController {

    var uid : String = ""
    
    @IBOutlet weak var UserImage: UIImageView!
    @IBOutlet weak var UserNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UserImage.image = CurrentUserPhoto
        UserNameLabel.text = CurrentUserName
        
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
