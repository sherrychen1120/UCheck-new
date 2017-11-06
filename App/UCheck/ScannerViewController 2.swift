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
    
    //Variables related to current store recommendation
    var CurrentStoreRecommendationList : [Item] = []
    
    @IBOutlet weak var MyCouponButton: UIButton!
    @IBOutlet weak var ButtonView: UIView!
    @IBOutlet weak var CheckoutButton: UIButton!
    @IBAction func CheckoutButton(_ sender: Any) {
        performSegue(withIdentifier: "ScanningToCheckout", sender: nil)
    }
    @IBOutlet weak var RecommendationCollection: UICollectionView!
    @IBOutlet weak var RecommendationView: UIView!
    @IBAction func MyCouponButton(_ sender: Any) {
        self.performSegue(withIdentifier: "ScanningToMyCoupons", sender: nil)
    }
    
    /*@IBAction func MenuButton(_ sender: Any) {
        performSegue(withIdentifier: "ScanningToMenu", sender: nil)
    }*/
    
    /*@IBAction func ShoppingCartButton(_ sender: Any) {
        performSegue(withIdentifier: "ScanningToCart", sender: nil)
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Customize the navigation bar
        /*self.navigationController!.navigationBar.backgroundColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController!.navigationBar.barTintColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController!.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 19)!]
        self.navigationController?.setNavigationBarHidden(false, animated: true)*/
        
        self.navigationController!.navigationBar.backgroundColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController!.navigationBar.barTintColor = UIColor(red:124/255.0, green:28/255.0, blue:22/255.0, alpha:1.0)
        self.navigationController!.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 19)!]
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.navigationItem.title = "Scanning"

        //Customize the checkout button
        CheckoutButton.layer.cornerRadius = 9
        
        //Collection view delegate & data source
        RecommendationCollection.delegate = self
        RecommendationCollection.dataSource = self
        
        //Scanner Setup
        self.scannerSetup()
        print("view did load scanner setup.")
        
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
        self.navigationItem.leftBarButtonItem = menuBarButton
        
        //Update collection view
        self.getStoreRecommendations(handleComplete:{
            DispatchQueue.main.async {
                self.RecommendationCollection.reloadData()
            }
        })
    }
    
    @objc func ShoppingCartButtonPressed(){
        performSegue(withIdentifier: "ScanningToCart", sender: nil)
    }
    
    @objc func MenuButtonPressed(){
        performSegue(withIdentifier: "ScanningToMenu", sender: nil)
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
            view.bringSubview(toFront: RecommendationView)
            view.bringSubview(toFront: ButtonView)
            view.bringSubview(toFront: MyCouponButton)
            
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
        } else if let controller = segue.destination as? MyCouponsViewController {
            captureSession?.stopRunning()
            slideInTransitioningDelegate.direction = .bottom
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
            controller.delegate = self
        }

    }
    
  
    @IBAction func unwindToScanner(segue: UIStoryboardSegue) {
        self.scannerSetup()
        print("unwindSegue scannerSetup")
    }
    
    //CollectionView delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    //CollectionView datasource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath as IndexPath) as! ShoppingRecommendationItemCollectionViewCell
        
        if (indexPath.row < CurrentStoreRecommendationList.count){
            var curr_item = CurrentStoreRecommendationList[indexPath.row]
            
            if let source_image = curr_item.item_image{
                cell.ItemImage.image = source_image
            }
                
            if (curr_item.has_itemwise_discount != "none"){
                    cell.ItemPrice.isHidden = false
                    cell.OriginalPrice.isHidden = false
                    cell.DeleteLine.isHidden = false
                    cell.PromoMessage.isHidden = false
                    
                    cell.ItemPrice.text = "$" + curr_item.discount_price
                    cell.OriginalPrice.text = "$" + curr_item.price
                    cell.PromoMessage.text = curr_item.discount_content
                
            } else if (curr_item.has_coupon != "none"){
                    cell.ItemPrice.isHidden = false
                    cell.OriginalPrice.isHidden = false
                    cell.DeleteLine.isHidden = false
                    cell.PromoMessage.isHidden = false
                    
                    cell.ItemPrice.text = "$" + curr_item.coupon_applied_unit_price
                    cell.OriginalPrice.text = "$" + curr_item.price
                    cell.PromoMessage.text = curr_item.coupon_content
            } else {
                    cell.ItemPrice.isHidden = false
                    cell.OriginalPrice.isHidden = true
                    cell.PromoMessage.isHidden = true
                    cell.DeleteLine.isHidden = true
                    
                    cell.ItemPrice.text = "$" + curr_item.price
            }
                
            return cell
            
        } else {
            cell.ItemPrice.isHidden = true
            cell.OriginalPrice.isHidden = true
            cell.DeleteLine.isHidden = true
            cell.PromoMessage.isHidden = true
                
            return cell
        }

    }
    
    //CollectionView delegate flow layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let itemsPerRow:CGFloat = 3
        let hardCodedPadding:CGFloat = 10
        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding - 5
        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
        
        print("itemWidth = " + String(describing: itemWidth))
        print("itemHeight = " + String(describing: itemHeight))
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func getStoreRecommendations(handleComplete:@escaping ()->()){
        for item in ItemwiseRecommendationList {
            if (item.store_id == CurrentStore) && ((item.has_coupon != "none") || (item.has_itemwise_discount != "none")) {
                CurrentStoreRecommendationList.append(item)
            }
        }
        CurrentStoreRecommendationList.sort{ $0.score > $1.score}

    }
    
    // MARK: - show alert
    func showAlert(withMessage: String) {
        let alert = UIAlertController(title: "Eh Oh", message: withMessage, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

}
