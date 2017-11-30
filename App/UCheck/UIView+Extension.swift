import Foundation
import UIKit

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
