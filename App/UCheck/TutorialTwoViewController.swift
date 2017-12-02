//
//  TutorialTwoViewController.swift
//  UCheck
//
//  Created by Ezaan Mangalji on 2017-12-02.
//

import UIKit

class TutorialTwoViewController: UIViewController {
    @IBOutlet weak var gradientView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientView.setGradientBackground(colorOne: Colors.lightWhite, colorTwo: UIColor.white)
        CATransaction.commit()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

