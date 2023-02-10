import UIKit

extension UIEdgeInsets {
    static func random() -> Self {
        return UIEdgeInsets(
            top: .random(in: 0...100),
            left: .random(in: 0...100),
            bottom: .random(in: 0...100),
            right: .random(in: 0...100))
    }
}
