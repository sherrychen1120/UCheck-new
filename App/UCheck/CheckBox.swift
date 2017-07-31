//
//  CheckBox.swift
//  UCheck
//
//  Created by Sherry Chen on 7/4/17.
//
//

import UIKit

class CheckBox: UIButton {

    // Images
    let checkedImage = UIImage(named: "check_box_checked")! as UIImage
    let uncheckedImage = UIImage(named: "check_box_empty")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControlState.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControlState.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.isChecked = false
    }
    
    func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }

}
