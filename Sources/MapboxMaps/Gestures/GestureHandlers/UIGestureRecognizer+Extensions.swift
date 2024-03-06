import UIKit

/// Can be used to distinguish between recognizers attached to the SwiftUI hosting view and recognizers added tp underlying UIKit view
/// SwiftUI API's add recognizers to the hosting view
extension UIGestureRecognizer {
    func attachedToSameView(as other: UIGestureRecognizer) -> Bool {
       view === other.view
    }
}

/// Can be used to decide whether the recognizer should receive the touch.
/// In case where the recognizer is known to be attached to some view we may ignore any touches that is going to be delievered to unrelated view.
extension UIGestureRecognizer {
    func attachedToSameView(as touch: UITouch) -> Bool {
        view === touch.view
    }
}
