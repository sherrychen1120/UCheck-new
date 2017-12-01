import Foundation
import UIKit
import SwiftKeychainWrapper
import Firebase
import FBSDKLoginKit

extension UIView {
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

struct Colors {
    static let darkRed = UIColor(red: 137.0/255.0, green: 3.0/255.0, blue: 9.0/255.0, alpha: 1.0)
    static let lightRed = UIColor(red: 203.0/255.0, green: 93.0/255.0, blue: 94.0/255.0, alpha: 1.0)
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func saveImage (image: UIImage, path: String) -> Void {
    if let png = UIImagePNGRepresentation(image) {
        let filename = getDocumentsDirectory().appendingPathComponent(path)
        try? png.write(to: filename)
    }
}

func loadImageFromPath(path: String) -> UIImage? {
    let filename = getDocumentsDirectory().appendingPathComponent(path).path
    let image = UIImage(contentsOfFile: filename)
    
    if image == nil {
        print("missing image at: \(path)")
    }
    print("Loading image from path: \(path)") // debug to find path
    return image
}


func logoutProcedure(EmailOrFB : String?, removeUserDefaultsForKey: String?, deleteProfilePic: Bool, cleanCurrentSession: Bool, cleanShoppingCart: Bool, handleComplete:@escaping ()->()){
    //1. Remove email-password pair from KeychainWrapper if logged in through "Email";
    //Log out of FB if logged in through "FB";
    //Value == nil otherwise.
    if (EmailOrFB == "Email"){
        let removeEmail: Bool = KeychainWrapper.standard.removeObject(forKey: "email")
        let removePassword: Bool = KeychainWrapper.standard.removeObject(forKey: "password")
        print("Successfully removed email: \(removeEmail);")
        print("Successfully removed password: \(removePassword).")
    } else if (EmailOrFB == "FB"){
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    //2. Remove User Defaults, if requested
    if let key = removeUserDefaultsForKey{
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
    }
    
    //3. Delete Profile Pic, if requested
    //TODO
    
    //4. Clean current session objects
    if (cleanCurrentSession){
        CurrentUser = ""
        CurrentUserName = ""
        CurrentUserId = ""
        CurrentUserPhoto = nil
    }
    
    //5. Clean Shopping Cart
    ShoppingCart.clear()
    
    //6. Sign out through Firebase, and call completion handler
    if FIRAuth.auth()?.currentUser != nil{
        do{
            try! FIRAuth.auth()!.signOut()
            print("Firebase signed out")
        }
        handleComplete()
    } else {
        handleComplete()
    }
    
}
