import UIKit

extension UIFont {
    static func safeMonospacedSystemFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        if #available(iOS 13.0, *) {
            return monospacedSystemFont(ofSize: size, weight: weight)
        }
        return monospacedDigitSystemFont(ofSize: size, weight: weight)
    }
}
