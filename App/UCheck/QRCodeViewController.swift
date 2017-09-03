//
//  QRCodeViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 9/2/17.
//
//

import UIKit

class QRCodeViewController: UIViewController {

    @IBOutlet weak var QRCodeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toFinish))
        QRCodeImage.isUserInteractionEnabled = true
        QRCodeImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func toFinish(){
        performSegue(withIdentifier: "QRCodeToFinish", sender: nil)
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
