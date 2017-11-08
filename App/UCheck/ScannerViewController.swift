//
//  ScannerViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/15/17.
//
//

import UIKit
import AVFoundation
import Firebase
import SwiftKeychainWrapper

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate,  communicationScanner {
    
    //Scanner-related variables
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var barCodeFrameView:UIView?
    
    //Firebase Ref
    let ref = FIRDatabase.database().reference(withPath: "inventory/\(CurrentStore)")
    
    //Half-modal view controller variables
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    
    //CurrItem
    var currItem: Item?
    
    //Transitioning Delegate for Menu
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    //Variables related to current store recommendation
    var CurrentStoreRecommendationList : [Item] = []
    
    @IBOutlet weak var LocationIcon: UIImageView!
    @IBOutlet weak var CurrentStoreLabel: UILabel!
    @IBOutlet weak var ScanningTitle: UILabel!
    @IBOutlet weak var ShoppingCartButton: UIButton!
    @IBOutlet weak var MenuButton: UIButton!
    @IBOutlet weak var LogOutButton: UIButton!
    @IBOutlet weak var ButtonView: UIView!
    @IBOutlet weak var CheckoutButton: UIButton!
    @IBAction func CheckoutButton(_ sender: Any) {
        performSegue(withIdentifier: "ScanningToCheckout", sender: nil)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()

        //Customize the checkout button
        CheckoutButton.layer.cornerRadius = 9
        
        //Scanner Setup
        self.scannerSetup()
        print("view did load scanner setup.")
        
        //Hide the navigation bar...?
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        /*
        //Shopping cart bar button setup
        let button: UIButton = UIButton(type: .custom)
        button.setImage(UIImage(named: "shopping_cart_white.png"), for: .normal)
        button.addTarget(self, action:#selector(ShoppingCartButtonPressed), for: .touchUpInside)
        button.frame = CGRect(x:0, y:0, width:31, height:31)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        //Menu bar button setup
        let menubutton: UIButton = UIButton(type: .custom)
        menubutton.setImage(UIImage(named: "menu_white.png"), for: .normal)
        menubutton.addTarget(self, action:#selector(MenuButtonPressed), for: .touchUpInside)
        menubutton.frame = CGRect(x:0, y:0, width:31, height:31)
        menubutton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        let menuBarButton = UIBarButtonItem(customView: menubutton)
        self.navigationItem.leftBarButtonItem = menuBarButton*/
        
    }
    
    @IBAction func MenuButton(_ sender: Any) {
        self.performSegue(withIdentifier: "ScanningToMenu", sender: sender)
    }
    
    @IBAction func ShoppingCartButton(_ sender: Any) {
        self.performSegue(withIdentifier: "ScanningToCart", sender: sender)
    }
    
    func scannerSetup(){
        //Scanner set up
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypePDF417Code]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            view.layer.addSublayer(videoPreviewLayer!)
            videoPreviewLayer?.frame = view.layer.bounds
            
            // Start video capture.
            captureSession?.startRunning()
            
            // Initialize QR Code Frame to highlight the QR code
            barCodeFrameView = UIView()
            
            if let barCodeFrameView = barCodeFrameView {
                barCodeFrameView.layer.borderColor = UIColor.red.cgColor
                barCodeFrameView.layer.borderWidth = 2
                view.addSubview(barCodeFrameView)
                view.bringSubview(toFront: barCodeFrameView)
            }
            
            //Bring the subviews to front
            view.bringSubview(toFront: ButtonView)
            view.bringSubview(toFront: LogOutButton)
            view.bringSubview(toFront: MenuButton)
            view.bringSubview(toFront: ShoppingCartButton)
            view.bringSubview(toFront: ScanningTitle)
            view.bringSubview(toFront: LocationIcon)
            view.bringSubview(toFront: CurrentStoreLabel)
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            barCodeFrameView?.frame = CGRect.zero
            print("No bar code is detected")
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        captureSession?.stopRunning()
        
        if (metadataObj.type == AVMetadataObjectTypeEAN8Code
        || metadataObj.type == AVMetadataObjectTypeEAN13Code
        || metadataObj.type == AVMetadataObjectTypePDF417Code) {
            // If the found metadata is equal to the bar code metadata then set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            barCodeFrameView?.frame = barCodeObject!.bounds       
                        
            if metadataObj.stringValue != nil {
                let code = metadataObj.stringValue
                print("bar code detected = " + code!)
                
                //Read object from Firebase
                ref.observe(.value, with: { snapshot in
                    
                    for item in snapshot.children {
                        let newItem = Item(snapshot: item as! FIRDataSnapshot)
                        if (newItem.code == code){
                            self.currItem = newItem
                        }
                    }
                    
                    if (self.currItem != nil){
                        print(self.currItem!.item_name)
                        self.captureSession = nil
                        
                        //Add to shopping cart
                        ShoppingCart.addItem(newItem: self.currItem!)
                        ShoppingCart.listItems()
                        
                        //Show ItemDetail VC
                        //Pass the currItem to the next VC
                        self.performSegue(withIdentifier: "ScanningToItemDetail", sender: self)
                    } else {
                        self.showAlert(withMessage : "Item not found.")
                        self.scannerSetup()
                    }
                    
                })
                
        }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ScanningToItemDetail"{
            super.prepare(for: segue, sender: sender)
            
            let nextScene = segue.destination as! ItemDetailViewController
            nextScene.currItem = self.currItem!
            self.currItem = nil
            
            self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: segue.destination)
            
            nextScene.modalPresentationStyle = .custom
            nextScene.transitioningDelegate = self.halfModalTransitioningDelegate

        } else if segue.identifier == "ScanningToMenu"{
            let controller = segue.destination as! MenuViewController
            captureSession?.stopRunning()
            slideInTransitioningDelegate.direction = .left
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
            controller.delegate = self
        } else if segue.identifier == "ScanningToCart" {
            let controller = segue.destination as! ShoppingCartViewController
            captureSession?.stopRunning()
            slideInTransitioningDelegate.direction = .right
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
            controller.delegate = self
        } else if segue.identifier == "ScanningToCheckout" {
            captureSession?.stopRunning()
        }

    }
    
    @IBAction func unwindToScanner(segue: UIStoryboardSegue) {
        self.scannerSetup()
        //Make sure the navigation bar is hidden...?
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        print("unwindSegue scannerSetup")
    }
    
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
    
    // MARK: - show alert
    func showAlert(withMessage: String) {
        let alert = UIAlertController(title: "Eh Oh", message: withMessage, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

}
