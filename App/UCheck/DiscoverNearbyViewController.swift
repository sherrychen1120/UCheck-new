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
    
    //If we should reload itemwise recommendation, lunch, coupon or rewards sections
    var should_reload_recom = false
    var should_reload_lunch = false
    var should_reload_coupon = false
    var should_reload_rewards = false

    @IBAction func LogOutButton(_ sender: Any) {
        let removeEmail: Bool = KeychainWrapper.standard.removeObject(forKey: "email")
        let removePassword: Bool = KeychainWrapper.standard.removeObject(forKey: "password")
        print("Successfully removed email: \(removeEmail);")
        print("Successfully removed passwordd: \(removePassword).")
        
        if FIRAuth.auth()?.currentUser != nil{
            //There is a user signed in
            do{
                try! FIRAuth.auth()!.signOut()
                
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
        
        //Itemwise Recommendation: Get items & pictures and refresh
        self.getItems(handleComplete:{
            self.getLunchItems(handleComplete:{
                self.getCouponItems(handleComplete:{
                    self.getRewardsItems(handleComplete:{
                        DispatchQueue.main.async {
                            self.TableArea.reloadData()
                            self.should_reload_recom = true
                            self.should_reload_lunch = true
                            self.should_reload_coupon = true
                        }
                    })
                })
            })
        })
        
        
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
            if should_reload_recom == true{
                cell.reloadRecommendations()
                should_reload_recom = false
            }
            return cell
        } else if (indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "LunchNearbyCell", for: indexPath) as! LunchNearbyTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle(rawValue: 0)!
            if should_reload_lunch == true{
                cell.reloadLunch()
                should_reload_lunch = false
            }
            return cell
        } else if (indexPath.section == 2){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CouponsCell", for: indexPath) as! CouponsTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle(rawValue: 0)!
            if should_reload_coupon == true{
                cell.reloadCoupons()
                should_reload_coupon = false
            }
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
            return 300
        } else if (indexPath.section == 1){
            return 200
        } else if (indexPath.section == 2){
            return 350
        } else {
            return 250
        }
    }
   
    func getItems(handleComplete:@escaping (()->())){
        let uid = CurrentUserId
        let recom_ref = FIRDatabase.database().reference(withPath: "user-profiles/\(uid)/itemwise_recommendation")
        
        //Read objects from Firebase
        recom_ref.observe(.value, with: { snapshot in
            
            //print(snapshot)
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            
            //sort all the scores in ascending order
            let allBarcodes = snapshotValue.allKeys as! [String]
            
            //Retrieve all the items, put them into the array
            for barcode in allBarcodes {
                let recom_item_dict = snapshotValue[barcode] as! [String:AnyObject]
                //print(recom_item_dict)
                let recom_item = Item(snapshotValue: recom_item_dict, barcode: barcode)
                let store_id = recom_item.store_id
                
                ItemwiseRecommendationList.append(recom_item)
                if (!ItemwiseRecommendationStoreIds.contains(store_id)){
                    ItemwiseRecommendationStoreIds.append(store_id)
                }
            }
            
            ItemwiseRecommendationList.sort{ $0.score > $1.score}
            
            self.getPictures(handleComplete: {
                handleComplete()
            })
        })
        
    }
    
    func getPictures(handleComplete:@escaping (()->())){
        var processed = 0
        for item in ItemwiseRecommendationList{
            let item_bar_code = item.code
            let store_id = item.store_id
            
            let image_ref = FIRStorage.storage().reference(withPath:"inventory/\(store_id)/\(item_bar_code).png")
            
            image_ref.data(withMaxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    let image = UIImage(data: data!)
                    item.addImage(source: image)
                    print("Image saved for \(item.name)")
                    
                    self.getStoreLogo(store_id:store_id, item:item, completion:{
                        processed = processed + 1
                        if (processed == ItemwiseRecommendationList.count) {
                            handleComplete()
                        }
                    })
                }
            }
        }
    }
    
    func getStoreLogo(store_id: String, item: Item, completion:@escaping ()->()){
        
        let c = store_id.characters
        let divider = c.index(of: "_")!
        let store_name = store_id[store_id.startIndex..<divider]
        
        let image_ref = FIRStorage.storage().reference(withPath:"store_logos/\(store_name).png")
        
        image_ref.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let image = UIImage(data: data!)
                item.addStoreLogo(source: image)
                print("Store logo saved for \(store_name)")
            }
            completion()
        }
        
    }
    
    func getLunchItems(handleComplete:@escaping ()->()){
        let uid = CurrentUserId
        let location_ref = FIRDatabase.database().reference(withPath: "user_preferred_locations/\(uid)/inferred_location")
        
        location_ref.observe(.value, with: { snapshot in
            //print(snapshot)
            let snapshotValue = snapshot.value as! NSDictionary
            let city = snapshotValue["city"] as! String
            let zip_code = snapshotValue["zip_code"] as! String
            
            let recom_ref = FIRDatabase.database().reference(withPath: "temporary_promotions/\(city)/\(zip_code)")
            recom_ref.observe(.value, with:{snapshot in
                print(snapshot)
                for item in snapshot.children{
                    let new_lunch_item = LunchItem(snapshot_source : item as! FIRDataSnapshot)
                    
                    //add image
                    let image_ref = FIRStorage.storage().reference(withPath:"temporary_promotions/\(city)/\(zip_code)/\(new_lunch_item.code).png")
                    
                    image_ref.data(withMaxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            let image = UIImage(data: data!)
                            new_lunch_item.addImage(image_source: image)
                            print("Lunch item image saved for \(new_lunch_item.code)")
                            LunchNearbyList.append(new_lunch_item)
                        }
                        
                        if (LunchNearbyList.count == 3){
                            handleComplete()
                        }
                    }

                }
                
            })
        })
    }
    
    func getCouponItems(handleComplete:@escaping ()->()){
        let uid = CurrentUserId
        let coupons_ref = FIRDatabase.database().reference(withPath: "user-profiles/\(uid)/coupons")
        
        coupons_ref.observe(.value, with:{snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let allCouponIds = snapshotValue.allKeys
            
            for key in allCouponIds {
                let couponDict = snapshotValue[key] as! [String:Int]
                let score = couponDict["score"]!
                let newCoupon = CouponForDisplay(id_source: key as! String, score_source: score)
                CouponsToDisplayList.append(newCoupon)
            }
            
            CouponsToDisplayList.sort{$0.score > $1.score}
            
            //add image
            var finished = 0
            for index in 0...2{
                let currCoupon = CouponsToDisplayList[index]
                let image_ref = FIRStorage.storage().reference(withPath:"coupons/\(currCoupon.coupon_id).png")
                
                image_ref.data(withMaxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        let image = UIImage(data: data!)
                        currCoupon.addImage(image_source: image)
                        print("Coupon image saved for \(currCoupon.coupon_id)")
                    }
                    
                    finished = finished + 1
                    if (finished == 3){
                        handleComplete()
                    }
                    
                }

            }
            
        
        })

    }

    func getRewardsItems(handleComplete:@escaping ()->()){
        let uid = CurrentUserId
        let user_ref = FIRDatabase.database().reference(withPath: "user-profiles/\(uid)")
        
        user_ref.observe(.value, with:{snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let phone_no = snapshotValue["phone_no"] as! String
            let membership_dict = snapshotValue["membership"] as! NSDictionary
            let allMemberships = membership_dict.allKeys
            
            for store_name in allMemberships{
                let membership_ref = FIRDatabase.database().reference(withPath: "membership_users/\(store_name)/\(phone_no)")
                let store_name_string = String(describing: store_name)
                
                membership_ref.observe(.value, with:{msnapshot in
                    let new_membership_obj = MembershipProgram(store_name_source: store_name_string, snapshot_source: msnapshot)
                    
                    //Add logo
                    let image_ref = FIRStorage.storage().reference(withPath:"store_logos/\(store_name_string).png")
                    
                    image_ref.data(withMaxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            let image = UIImage(data: data!)
                            new_membership_obj.addLogo(image_source: image)
                            print("Membership logo saved for \(store_name_string)")
                            MembershipList.append(new_membership_obj)
                        }
                        
                        if MembershipList.count == 2 {
                            handleComplete()
                        }
                    }

                    
                })
            }
            
        })
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
