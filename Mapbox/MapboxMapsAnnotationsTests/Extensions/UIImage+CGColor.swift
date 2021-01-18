import UIKit

extension UIImage {
    static func squareImage(with color: UIColor, size: CGSize) -> UIImage {
        let imageSize = CGSize(width: size.width, height: size.height)

        return UIGraphicsImageRenderer(size: imageSize).image { rendererContext in
            color.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: imageSize))
        }
    }
}
