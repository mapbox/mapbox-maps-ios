import UIKit

internal class GestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {

    /// The view that all gestures operate on
    private weak var view: UIView?

    internal init(view: UIView) {
        self.view = view
    }

    internal func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        // Handle pitch tilt gesture
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            if panGesture.minimumNumberOfTouches == 2 {

                let leftTouchPoint = panGesture.location(ofTouch: 0, in: view)
                let rightTouchPoint = panGesture.location(ofTouch: 1, in: view)

                guard let touchPointAngle = GestureUtilities.angleBetweenPoints(leftTouchPoint,
                                                                                rightTouchPoint) else { return false }

                let horizontalTiltTolerance = 45.0

                // If the angle between the pan touchpoints is greater then the
                // tolerance specified, don't start the gesture.
                if fabs(touchPointAngle) > horizontalTiltTolerance {
                    return false
                }
            }
        }

        return true
    }

    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return (gestureRecognizer is UIPinchGestureRecognizer || gestureRecognizer is UIRotationGestureRecognizer) &&
            (otherGestureRecognizer is UIPinchGestureRecognizer || otherGestureRecognizer is UIRotationGestureRecognizer)
    }
}
