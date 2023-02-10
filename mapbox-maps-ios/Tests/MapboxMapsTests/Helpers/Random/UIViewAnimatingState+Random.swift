import UIKit

extension UIViewAnimatingState {
    static func random() -> Self {
        return [.active, .inactive, .stopped].randomElement()!
    }
}
