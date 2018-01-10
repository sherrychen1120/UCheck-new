//
//  TutorialOneViewController.swift
//  UCheck
//
//  Created by Ezaan Mangalji on 2017-12-02.
//

import UIKit

class TutorialOneViewController: UIViewController {
    @IBOutlet weak var gradientLayer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.setGradientBackground(colorOne: UIColor.clear, colorTwo: UIColor.white)
        CATransaction.commit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
