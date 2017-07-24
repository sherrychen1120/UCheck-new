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

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, communicationScanner {
    
    //Scanner-related variables
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var barCodeFrameView:UIView?
    
    //Half-modal view controller variables
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    
    //Firebase Ref
    let ref = FIRDatabase.database().reference(withPath: "inventory/\(CurrentStore)")
    
    //CurrItem
    var currItem: Item?
    
    //Transitioning Delegate for Menu
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    @IBOutlet weak var ButtonView: UIView!
    @IBOutlet weak var ScanningArea: UIView!
    @IBOutlet weak var CheckoutButton: UIButton!
    @IBAction func CheckoutButton(_ sender: Any) {
        performSegue(withIdentifier: "ScanningToCheckout", sender: nil)
    }
    @IBOutlet weak var RecommendationCollection: UICollectionView!
    
    @IBAction func MenuButton(_ sender: Any) {
        performSegue(withIdentifier: "ScanningToMenu", sender: nil)
    }
    
    @IBAction func ShoppingCartButton(_ sender: Any) {
        performSegue(withIdentifier: "ScanningToCart", sender: nil)
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

        //Customize the checkout button
        CheckoutButton.layer.cornerRadius = 9
        
        //Collection view delegate & data source
        RecommendationCollection.delegate = self
        RecommendationCollection.dataSource = self
        
        self.scannerSetup()
        print("view did load scanner setup.")
    }
    
    /*override func viewDidAppear(_ animated: Bool) {
        self.scannerSetup()
        print("view did appear scanner setup.")
        super.viewDidAppear(animated)
     }*/
    
    
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
            
            view.bringSubview(toFront: RecommendationCollection)
            view.bringSubview(toFront: ButtonView)
            
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
                print(code!)
                
                //Read object from Firebase
                ref.observe(.value, with: { snapshot in
                    print(snapshot)
                    for item in snapshot.children {
                        let newItem = Item(snapshot: item as! FIRDataSnapshot)
                        if (newItem.code == code){
                            self.currItem = newItem
                        }
                    }
                    
                    if (self.currItem != nil){
                        print(self.currItem!.name)
                        self.captureSession = nil
                        
                        //Add to shopping cart
                        ShoppingCart.addItem(newItem: self.currItem!)
                        ShoppingCart.listItems()
                        
                        //Show ItemDetail VC
                        //TODO: Pass the currItem to the next VC
                        self.performSegue(withIdentifier: "ScanningToItemDetail", sender: self)
                    } else {
                        print("Item not found.")
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
            
            self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: segue.destination)
            
            nextScene.modalPresentationStyle = .custom
            nextScene.transitioningDelegate = self.halfModalTransitioningDelegate

        } else if let controller = segue.destination as? MenuViewController {
            captureSession?.stopRunning()
            slideInTransitioningDelegate.direction = .left
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
            controller.delegate = self
            
        } else if let controller = segue.destination as? ShoppingCartViewController {
            captureSession?.stopRunning()
            slideInTransitioningDelegate.direction = .right
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
            controller.delegate = self
        } else if let controller = segue.destination as? CheckOutViewController {
            captureSession?.stopRunning()
        }

    }
    
  
    @IBAction func unwindToScanner(segue: UIStoryboardSegue) {
        self.scannerSetup()
        print("unwindSegue scannerSetup")
    }
    
    //CollectionView delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    //CollectionView datasource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath as IndexPath)
        return cell
    }
    
    //CollectionView delegate flow layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let itemsPerRow:CGFloat = 4
        let hardCodedPadding:CGFloat = 10
        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding - 5
        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
        
        print("itemWidth = " + String(describing: itemWidth))
        print("itemHeight = " + String(describing: itemHeight))
        
        return CGSize(width: itemWidth, height: itemHeight)
    }

}
