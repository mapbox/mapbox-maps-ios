import Foundation
import UIKit

extension UIImage {
    class var empty: UIImage {
        UIGraphicsBeginImageContext(.init(width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
