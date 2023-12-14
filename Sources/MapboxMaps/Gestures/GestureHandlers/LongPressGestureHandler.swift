import UIKit

final class LongPressGestureHandler: NSObject, UIGestureRecognizerDelegate {
    let recognizer = UILongPressGestureRecognizer()

    /// Returns signal that retains self while being observed.
    var signal: Signal<(CGPoint, UIGestureRecognizer.State)> {
        Signal(gesture: recognizer).map { ($0.location(in: $0.view), $0.state) }
    }

    override init() {
        super.init()
        recognizer.delegate = self
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        assert(gestureRecognizer == recognizer)

        guard gestureRecognizer.attachedToSameView(as: otherGestureRecognizer) else { return true }

        return otherGestureRecognizer is UILongPressGestureRecognizer
    }
}
