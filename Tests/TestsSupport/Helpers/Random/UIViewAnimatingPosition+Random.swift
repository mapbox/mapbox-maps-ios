import UIKit

extension UIViewAnimatingPosition {
    static func random() -> Self {
        [.start, .current, .end].randomElement()!
    }
}
