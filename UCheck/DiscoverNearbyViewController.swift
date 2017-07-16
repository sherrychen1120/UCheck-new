//
//  DiscoverNearbyViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/7/17.
//
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class DiscoverNearbyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func LogOutButton(_ sender: Any) {
        let removeEmail: Bool = KeychainWrapper.standard.remove(key: "email")
        let removePassword: Bool = KeychainWrapper.standard.remove(key: "password")
        print("Successfully removed email: \(removeEmail);")
        print("Successfully removed passwordd: \(removePassword).")
        
        if FIRAuth.auth()?.currentUser != nil{
            //There is a user signed in
            do{
                try? FIRAuth.auth()!.signOut()
                if FIRAuth.auth()?.currentUser == nil{
                    let loginVC = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
                    self.present(loginVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBOutlet weak var TableArea: UITableView!
    @IBOutlet weak var ButtonArea: UIView!
    @IBOutlet weak var StartShoppingButton: UIButton!
    
    @IBAction func StartShoppingButton(_ sender: Any) {
        performSegue(withIdentifier: "DiscoverNearbyToFindStoreTip", sender: nil)
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
        
        //TableArea delegate and dataSource
        TableArea.delegate = self
        TableArea.dataSource = self
        
        //Shadow of the UIView around the button
        ButtonArea.layer.shadowColor = UIColor.black.cgColor
        ButtonArea.layer.shadowOpacity = 0.3
        ButtonArea.layer.shadowOffset = CGSize(width: 0, height: -5)
        ButtonArea.layer.shadowRadius = 3
        
        //StartShoppingButton
        StartShoppingButton.layer.cornerRadius = 9
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Customize the navigation bar
        self.navigationController!.navigationBar.backgroundColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController!.navigationBar.barTintColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController!.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 19)!]
        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendedForYouCell", for: indexPath) as! RecommendedForYouTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle(rawValue: 0)!
            return cell
        } else if (indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "LunchNearbyCell", for: indexPath) as! LunchNearbyTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle(rawValue: 0)!
            return cell
        } else if (indexPath.section == 2){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CouponsCell", for: indexPath) as! CouponsTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle(rawValue: 0)!
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RewardsCell", for: indexPath) as! MyRewardsTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle(rawValue: 0)!
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 227
        } else if (indexPath.section == 1 || indexPath.section == 2){
            return 188
        } else {
            return 210
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindToDiscoverNearby(segue: UIStoryboardSegue) {}

}
