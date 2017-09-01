//
//  MyCouponsViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 9/1/17.
//
//

import UIKit
import Firebase

class MyCouponsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var delegate: communicationScanner? = nil
    
    //Hard-coded my coupon list. Need to change later!
    var MyCouponsList = ["c711_001", "mc711_001", "c711_002"]
    var MyCouponsImages : [UIImage] = []
    
    @IBOutlet weak var CouponsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.CouponsCollectionView.delegate = self
        self.CouponsCollectionView.dataSource = self
        self.getCouponImages(handleComplete: {
            DispatchQueue.main.async {
                self.CouponsCollectionView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("my coupons will disappear")
        self.delegate?.scannerSetup()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath as IndexPath) as! MyCouponItemCollectionViewCell
        
        if MyCouponsImages.count > 0 {
            cell.ItemImage.image = MyCouponsImages[indexPath.row]
            
        }
        
        return cell
                    
    }
    
    func getCouponImages(handleComplete:@escaping ()->()){
        var finished = 0
        for index in 0...2{
            let coupon_id = MyCouponsList[index]
            let image_ref = FIRStorage.storage().reference(withPath:"coupons/\(coupon_id).png")
            
            image_ref.data(withMaxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let image = UIImage(data: data!){
                        self.MyCouponsImages.append(image)
                    }
                }
                
                finished = finished + 1
                if (finished == 3){
                    handleComplete()
                }
                
            }
            
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

}

extension MyCouponsViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let itemsToShow:CGFloat = 3
        let hardCodedPadding:CGFloat = 10
        let itemWidth = collectionView.bounds.width - 2 * hardCodedPadding
        let itemHeight = (collectionView.bounds.height / itemsToShow) - hardCodedPadding - 5
        
        //print("itemWidth = " + String(describing: itemWidth))
        //print("itemHeight = " + String(describing: itemHeight))
        //print("boundsHeight = " + String(describing: collectionView.bounds.height))
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
}

