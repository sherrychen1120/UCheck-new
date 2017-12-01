//
//  ShoppingHistoryViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 12/1/17.
//

import UIKit

class ShoppingHistoryViewController: UIViewController {

    @IBOutlet weak var HistoryListTableView: UITableView!
    @IBOutlet weak var BackButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Customize navBar
        navBar.backgroundColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        navBar.barTintColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        navBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.white,
             NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 19)!]
        let navItem = UINavigationItem(title: "Shopping History")
        let backItem = UIBarButtonItem(title: "< Back", style: .plain, target: nil, action: #selector(back))
        backItem.tintColor = UIColor.white
        navItem.leftBarButtonItem = backItem
        navBar.setItems([navItem], animated: false)
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
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
