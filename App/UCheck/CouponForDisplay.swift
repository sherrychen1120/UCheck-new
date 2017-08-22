//
//  CouponForDisplay.swift
//  UCheck
//
//  Created by Sherry Chen on 8/21/17.
//
//

import UIKit

class CouponForDisplay: NSObject {
    var coupon_id = ""
    var score = 0
    var coupon_image : UIImage?
    
    init(id_source : String, score_source : Int){
        coupon_id = id_source
        score = score_source
        coupon_image = nil
    }
    
    func addImage(image_source : UIImage?){
        coupon_image = image_source
    }
}
