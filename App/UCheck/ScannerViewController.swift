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
import SafariServices

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate,SFSafariViewControllerDelegate,communicationScanner {
    
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
    
    @IBOutlet weak var ScanningLabel: UILabel!
    @IBOutlet weak var ScanningArea: UIView!
    @IBOutlet weak var LocationIcon: UIImageView!
    @IBOutlet weak var CurrentStoreLabel: UILabel!
    @IBOutlet weak var ScanningTitle: UILabel!
    @IBOutlet weak var ShoppingCartButton: UIButton!
    @IBOutlet weak var MenuButton: UIButton!
    //@IBOutlet weak var LogOutButton: UIButton!
    @IBOutlet weak var CheckoutButton: UIButton!
    @IBAction func CheckoutButton(_ sender: Any) {
        performSegue(withIdentifier: "ScanningToCheckout", sender: nil)
    }
   
    override func viewDidLoad() {

        //Customize the checkout button
        CheckoutButton.layer.cornerRadius = 9
        
        //Scanner Setup
        self.scannerSetup()
        print("view did load scanner setup.")
        
        //Hide the navigation bar...?
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //TODO:
        // search based on email, get PP, uid
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.scannerSetup()
        print("view will appear scanner setup.") //Only load together with view did load
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
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.ean8,AVMetadataObject.ObjectType.upce, AVMetadataObject.ObjectType.qr]
                //captureMetadataOutput.availableMetadataObjectTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
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
            
            //Initialize Scanning Area
            if let ScanningArea = ScanningArea {
                ScanningArea.layer.borderColor = UIColor.green.cgColor
                ScanningArea.layer.backgroundColor = UIColor.clear.cgColor
                ScanningArea.layer.borderWidth = 2
                view.addSubview(ScanningArea)
                view.bringSubview(toFront: ScanningArea)
            }
            
            //Bring the subviews to front
            //view.bringSubview(toFront: LogOutButton)
            view.bringSubview(toFront: MenuButton)
            view.bringSubview(toFront: ShoppingCartButton)
            view.bringSubview(toFront: ScanningTitle)
            view.bringSubview(toFront: LocationIcon)
            view.bringSubview(toFront: CurrentStoreLabel)
            view.bringSubview(toFront: ScanningArea)
            view.bringSubview(toFront: ScanningLabel)
            view.bringSubview(toFront: CheckoutButton)
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if (metadataObjects.count == 0) {
            barCodeFrameView?.frame = CGRect.zero
            print("No bar code is detected")
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        captureSession?.stopRunning()
        
        
        if (metadataObj.type == AVMetadataObject.ObjectType.ean13 ||
            metadataObj.type == AVMetadataObject.ObjectType.ean8 ||
            metadataObj.type == AVMetadataObject.ObjectType.upce ||
            metadataObj.type == AVMetadataObject.ObjectType.qr) {
           
                        
            if metadataObj.stringValue != nil {
                // If the found metadata is equal to the bar code metadata then set the bounds
                /*if let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj){
                    barCodeFrameView?.frame = barCodeObject.bounds
                }*/
                
                let code = metadataObj.stringValue
                print("bar code detected = " + code!)
                
                //Read object from Firebase
                ref.observe(.value, with: { snapshot in
                    
                    for item in snapshot.children {
                        let newItem = Item(snapshot: item as! FIRDataSnapshot)
                        if (newItem.code == code || code == newItem.item_number){
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
        print("unwindSegue scannerSetup") //Doesn't work
    }
    
    @IBAction func unwindToScannerForLogout(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindToScannerForHelp(_ segue: UIStoryboardSegue){
        print("unwindToScannerForHelp")
        //self.showHelpform()
    }
    
    func showHelpForm() {
        //let urlString = "https://docs.google.com/forms/d/e/1FAIpQLSfO1WsJ23ByoqNSsgqGotFY4s7NKh6UEehAuV9tygDwUcFEyQ/viewform?usp=sf_link"
        let urlString = "http://www.google.com"
        
        if let url = URL(string: urlString) {
            
            //let config = SFSafariViewController.Configuration()
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            self.present(vc, animated: true)
            
            //vc.delegate = self
            //self.present(vc, animated: true)
        }
    }
    
    func toLogOut(){
        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
    /*func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("safariVCDidFinish Called.")
        controller.dismiss(animated: true, completion: nil)
    }*/
    
    
    /*@IBAction func LogOutButton(_ sender: Any) {
        let removeEmail: Bool = KeychainWrapper.standard.removeObject(forKey: "email")
        let removePassword: Bool = KeychainWrapper.standard.removeObject(forKey: "password")
        print("Successfully removed email: \(removeEmail);")
        print("Successfully removed passwordd: \(removePassword).")
        
        if FIRAuth.auth()?.currentUser != nil{
            //There is a user signed in
            do{
                try! FIRAuth.auth()!.signOut()
                
                if FIRAuth.auth()?.currentUser == nil{
                    ShoppingCart.clear()
                    let loginVC = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
                    self.present(loginVC, animated: true, completion: nil)
                }
            }
        }
    }*/
    
    // MARK: - show alert
    func showAlert(withMessage: String) {
        let alert = UIAlertController(title: "Eh Oh", message: withMessage, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

}
