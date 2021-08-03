import UIKit

/// The PinchGestureHandler is responsible for all `pinch` related infrastructure
/// Tells the view to update itself when required
internal class PinchGestureHandler: GestureHandler {
    private var previousScale: CGFloat = 0.0

    // The center point where the pinch gesture began
    private var initialPinchCenterPoint: CGPoint = .zero

    // The camera state when the pinch gesture began
    private var initialCameraState: CameraState!

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

            self.initialCameraState = self.delegate.cameraState()
            self.initialPinchCenterPoint = pinchCenterPoint

            /**
             TODO: Handle a concurrent rotate gesture here.
             Prioritize the correct gesture by comparing the velocity of competing gestures.
             */
        } else if pinchGestureRecognizer.state == .changed {
            if pinchGestureRecognizer.numberOfTouches < 2 {
                return
            }

            let zoomIncrement = log2(pinchGestureRecognizer.scale)
            delegate.pinchChanged(withZoomIncrement: zoomIncrement,
                                  targetAnchor: pinchCenterPoint,
                                  initialAnchor: self.initialPinchCenterPoint,
                                  initialCameraState: self.initialCameraState)

            previousScale = pinchGestureRecognizer.scale
        } else if pinchGestureRecognizer.state == .ended
            || pinchGestureRecognizer.state == .cancelled {

            delegate.pinchEnded()
        }
    }
}
