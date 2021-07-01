import UIKit

/// The PinchGestureHandler is responsible for all `pinch` related infrastructure
/// Tells the view to update itself when required
internal class PinchGestureHandler: GestureHandler {
    // Keep track of the previous pinch center point. This allows us to react
    // to panning while zooming
    private var previousPinchCenterPoint: CGPoint?

    internal var scale: CGFloat = 0.0

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

            scale = pow(2, delegate.scaleForZoom())
            delegate.gestureBegan(for: .pinch)

            /**
             TODO: Handle a concurrent rotate gesture here.
             Prioritize the correct gesture by comparing the velocity of competing gestures.
             */
            previousPinchCenterPoint = pinchCenterPoint
        } else if pinchGestureRecognizer.state == .changed {
            
            let newScale = scale * pinchGestureRecognizer.scale
            delegate.pinchScaleChanged(with: log2(newScale), andAnchor: pinchCenterPoint)
            
            if let previousPinchCenterPoint = self.previousPinchCenterPoint {
                let offset = CGSize(width:  pinchCenterPoint.x - previousPinchCenterPoint.x,
                                    height:  pinchCenterPoint.y - previousPinchCenterPoint.y)
                                
                self.delegate.pinchCenterMoved(offset: offset)
            }
            
            previousPinchCenterPoint = pinchCenterPoint
        } else if pinchGestureRecognizer.state == .ended
            || pinchGestureRecognizer.state == .cancelled {

            var velocity = pinchGestureRecognizer.velocity
            if velocity > -0.5 && velocity < 3 {
                velocity = 0
            }

            let duration = ((velocity > 0) ? 1 : 0.25) * decelerationRate
            let scale = self.scale * pinchGestureRecognizer.scale
            var newScale = scale

            if velocity >= 0 {
                newScale += scale * velocity * duration * 0.1
            } else {
                newScale += scale / (velocity * duration) * 0.1
            }

            if newScale <= 0 || log2(newScale) < minZoom {
                velocity = 0
            }

            previousPinchCenterPoint = nil
            
            let possibleDrift = velocity > 0.0 && duration > 0.0
            delegate.pinchEnded(with: log2(newScale), andDrift: possibleDrift, andAnchor: pinchCenterPoint)
        }
    }
}
