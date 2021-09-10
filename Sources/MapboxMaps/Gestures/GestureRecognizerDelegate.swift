import UIKit

internal class GestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {

    internal func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let view = gestureRecognizer.view else { return false }

        // Handle pitch tilt gesture
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            if panGesture.minimumNumberOfTouches == 2 {

                let leftTouchPoint = panGesture.location(ofTouch: 0, in: view)
                let rightTouchPoint = panGesture.location(ofTouch: 1, in: view)

                let touchPointAngle = GestureUtilities.angleBetweenPoints(leftTouchPoint, rightTouchPoint)

                // If the angle between the pan touchpoints is greater then the
                // tolerance specified, don't start the gesture.
                if fabs(touchPointAngle) > 45.0 {
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
