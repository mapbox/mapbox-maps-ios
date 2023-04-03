import UIKit

extension UIImage {

    static func emptyImage(with size: CGSize = CGSize(width: 20, height: 20)) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    static func generateSquare(color: UIColor) -> UIImage {
        return UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image {
            $0.cgContext.setFillColor(color.cgColor)
            $0.cgContext.fill([CGRect(x: 0, y: 0, width: 10, height: 10)])
        }
    }
}
