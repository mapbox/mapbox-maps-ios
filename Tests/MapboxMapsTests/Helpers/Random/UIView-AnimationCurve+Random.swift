import UIKit

extension UIView.AnimationCurve {
    static func random() -> Self {
        return [.linear, .easeIn, .easeOut, .easeInOut].randomElement()!
    }
}
