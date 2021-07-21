import UIKit

/// The PinchGestureHandler is responsible for all `pinch` related infrastructure
/// Tells the view to update itself when required
internal class PinchGestureHandler: GestureHandler {
    // Keep track of the previous pinch center point. This allows us to react
    // to panning while zooming
    private var previousPinchCenterPoint: CGPoint = .zero

    internal var previousScale: CGFloat = 0.0

    // TODO: Inject the deceleration rate as part of a configuration structure
    internal let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue

    // TODO: Inject the minimum zoom as part of a configuration structure
    internal let minZoom: CGFloat = 0.0

    // Initialize the handler which creates the panGestureRecognizer and adds to the view
    override internal init(for view: UIView, withDelegate delegate: GestureHandlerDelegate) {
        super.init(for: view, withDelegate: delegate)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinch)
        gestureRecognizer = pinch
    }

    @objc internal func handlePinch(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {

        delegate.cancelGestureTransitions()
        let pinchCenterPoint = pinchGestureRecognizer.location(in: view)

        if pinchGestureRecognizer.state == .began {

            self.previousScale = 1.0
            delegate.gestureBegan(for: .pinch)

            previousPinchCenterPoint = pinchCenterPoint

            /**
             TODO: Handle a concurrent rotate gesture here.
             Prioritize the correct gesture by comparing the velocity of competing gestures.
             */
        } else if pinchGestureRecognizer.state == .changed {

            let zoomIncrement = log2(pinchGestureRecognizer.scale / previousScale);
            delegate.pinchChanged(with: zoomIncrement, anchor: pinchCenterPoint, previousAnchor: previousPinchCenterPoint)

            previousScale = pinchGestureRecognizer.scale;
            previousPinchCenterPoint = pinchCenterPoint
        } else if pinchGestureRecognizer.state == .ended
            || pinchGestureRecognizer.state == .cancelled {

            delegate.pinchEnded(with: log2(pinchGestureRecognizer.scale / previousScale), andDrift: true, andAnchor: pinchCenterPoint)
        }
    }
}
