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
    static let lightWhite = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.2)
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func saveImage(image: UIImage, path: String) -> Void {
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

func removeImage(path: String) -> Void {
    let fileManager = FileManager.default
    let filename = getDocumentsDirectory().appendingPathComponent(path).path
    
    if (filename == "") {
        return;
    }
    
    try? fileManager.removeItem(atPath: filename)
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
    if (deleteProfilePic) {
        removeImage(path: "profilePicture.png")
    }
    
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


//function to format date_time for output
func formatDateTime(date_time : String) -> String{
    let r1 = date_time.startIndex..<date_time.index(date_time.startIndex, offsetBy: 4)
    let year = String(date_time[r1])
    
    let r2 = date_time.index(date_time.startIndex, offsetBy: 4)..<date_time.index(date_time.startIndex, offsetBy: 6)
    let month = date_time[r2]
    
    let r3 = date_time.index(date_time.startIndex, offsetBy: 6)..<date_time.index(date_time.startIndex, offsetBy: 8)
    let day = date_time[r3]
    
    let r4 = date_time.index(date_time.endIndex, offsetBy: -6)..<date_time.index(date_time.endIndex, offsetBy: -4)
    let hour = date_time[r4]
    
    let r5 = date_time.index(date_time.endIndex, offsetBy: -4)..<date_time.index(date_time.endIndex, offsetBy: -2)
    let minute = date_time[r5]
    
    let date = month + "/" + day + "/" + year
    let time = hour + ":" + minute
    let display_str = date + " " + time
    return display_str
}
