import UIKit

/// The PinchGestureHandler is responsible for all `pinch` related infrastructure
/// Tells the view to update itself when required
internal class PinchGestureHandler: GestureHandler {

    internal var scale: CGFloat = 0.0

    // TODO: Inject the deceleration rate as part of a configuration structure
    internal let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue

    // TODO: Inject the minimum zoom as part of a configuration structure
    internal let minZoom: CGFloat = 0.0

    // Initialize the handler which creates the panGestureRecognizer and adds to the view
    override internal init(for view: UIView, withDelegate delegate: GestureHandlerDelegate) {
        super.init(for: view, withDelegate: delegate)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(_:)))
        view.addGestureRecognizer(pinch)
        self.gestureRecognizer = pinch
    }

    @objc internal func handlePinch(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {

        self.delegate.cancelGestureTransitions()
        let pinchCenterPoint = pinchGestureRecognizer.location(in: self.view)

        if pinchGestureRecognizer.state == .began {

            self.scale = pow(2, self.delegate.scaleForZoom())
            self.delegate.gestureBegan(for: .pinch)

            /**
             TODO: Handle a concurrent rotate gesture here.
             Prioritize the correct gesture by comparing the velocity of competing gestures.
             */

        } else if pinchGestureRecognizer.state == .changed {

            let newScale = self.scale * pinchGestureRecognizer.scale
            self.delegate.pinchScaleChanged(with: log2(newScale), andAnchor: pinchCenterPoint)

        } else if pinchGestureRecognizer.state == .ended
            || pinchGestureRecognizer.state == .cancelled {

            var velocity = pinchGestureRecognizer.velocity
            if velocity > -0.5 && velocity < 3 {
                velocity = 0
            }

            let duration = ((velocity > 0) ? 1 : 0.25) * self.decelerationRate
            let scale = self.scale * pinchGestureRecognizer.scale
            var newScale = scale

            if velocity >= 0 {
                newScale += scale * velocity * duration * 0.1
            } else {
                newScale += scale / (velocity * duration) * 0.1
            }

            if newScale <= 0 || log2(newScale) < self.minZoom {
                velocity = 0
            }

            let possibleDrift = velocity > 0.0 && duration > 0.0

            self.delegate.pinchEnded(with: log2(newScale), andDrift: possibleDrift, andAnchor: pinchCenterPoint)
        }
    }
}
