import UIKit

/// Can be used to distinguish between recognizers attached to the SwiftUI hosting view and recognizers added tp underlying UIKit view
/// SwiftUI API's add recognizers to the hosting view
extension UIGestureRecognizer {
    func attachedToSameView(as other: UIGestureRecognizer) -> Bool {
       view === other.view
    }
}
