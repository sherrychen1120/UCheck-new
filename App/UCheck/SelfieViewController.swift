//
//  SelfieViewController.swift
//  UCheck
//
//  Created by Sherry Chen on 7/4/17.
//
//

import UIKit
import Firebase
import FirebaseStorage

class SelfieViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    let imagePicker = UIImagePickerController()
    var chosenImage : UIImage? = nil
    var storage: FIRStorage!
    var uid : String = ""
    let ref = FIRDatabase.database().reference(withPath: "user-profiles")
    
    @IBOutlet weak var ContinueButton: UIButton!
    @IBOutlet weak var SelfieInput: UIImageView!
    @IBOutlet weak var TakePhotoButton: UIButton!
    
    @IBAction func SkipButton(_ sender: Any) {
        self.performSegue(withIdentifier: "SelfieToAllSet", sender: self)
    }
    @IBAction func TakePhotoButton(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.cameraDevice = .front
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func ContinueButton(_ sender: Any) {
        if (chosenImage == nil){
            showAlert(withMessage: "Please take a photo of yourself to finish registration. You can make changes to it any time in the future.")
        } else {
            
            if let user = FIRAuth.auth()?.currentUser{
                uid = user.uid
            }
            
            let imageData = UIImagePNGRepresentation(chosenImage!)!
            
            //Create a reference to the profile pics folder
            let storageRef = storage.reference()
            let imagesRef = storageRef.child("profile_pics")
            
            // Create a reference to the file you want to upload
            let selfieRef = imagesRef.child("\(uid).png")
            
            // Upload file to Firebase Storage
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/png"
            selfieRef.put(imageData, metadata: metadata).observe(.success) { (snapshot) in
                // When the image has successfully uploaded, we get it's download URL
                let downloadURL = snapshot.metadata?.downloadURL()?.absoluteString
                
                //Upload the photo URL to user-profiles database
                let user_ref = self.ref.child(self.uid)
                user_ref.updateChildValues([
                    "photo_url" : downloadURL
                ])

            }
            
            CurrentUserPhoto = chosenImage!
                
            self.performSegue(withIdentifier: "SelfieToAllSet", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradientBackground(colorOne: Colors.darkRed, colorTwo: Colors.lightRed)

        ContinueButton.layer.cornerRadius = 9
        
        storage = FIRStorage.storage()
        
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]){
        chosenImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        SelfieInput.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(withMessage: String) {
        let alert = UIAlertController(title: "Eh Oh", message: withMessage, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
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
