import UIKit

extension UIImage {

    static func emptyImage(with size: CGSize = CGSize(width: 20, height: 20)) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
