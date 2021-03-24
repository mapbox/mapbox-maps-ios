import UIKit

/// The PanGestureHandler is responsible for all `pan` related infrastructure
/// Tells the view to update itself when required
internal class PanGestureHandler: GestureHandler {

    internal let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue
    internal var scrollMode = PanScrollingMode.horizontalAndVertical

    // Initialize the handler which creates the panGestureRecognizer and adds to the view
    internal init(for view: UIView, withDelegate delegate: GestureHandlerDelegate, panScrollMode: PanScrollingMode) {
        super.init(for: view, withDelegate: delegate)
        let pan = UIPanGestureRecognizer(target: self,
                                         action: #selector(handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        view.addGestureRecognizer(pan)
        gestureRecognizer = pan
        scrollMode = panScrollMode
    }

    // Handles the pan operation and calls the associated view
    @objc internal func handlePan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:

            let point = pan.location(in: pan.view)
            delegate.panBegan(at: point)
            delegate.gestureBegan(for: .pan)

        case .changed:
            let start = pan.location(in: pan.view)
            let delta = pan.translation(in: pan.view).applyPanScrollingMode(panScrollingMode: scrollMode)
            let end = CGPoint(x: start.x + delta.x, y: start.y + delta.y)
            delegate.panned(from: start, to: end)
            pan.setTranslation(.zero, in: pan.view)

        case .ended, .cancelled:
            let endPoint = pan.location(in: pan.view)
            var velocity = pan.velocity(in: pan.view)
            let velocityHypot = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))

            if decelerationRate == 0.0 || velocityHypot < 1000 {
                velocity = CGPoint.zero
            }

            var driftOffset = CGPoint.zero
            if velocity != CGPoint.zero { // There is a potential drift after the gesture has ended
                driftOffset = CGPoint(x: velocity.x * decelerationRate / 4,
                                     y: velocity.y * decelerationRate / 4)
                                    .applyPanScrollingMode(panScrollingMode: scrollMode)
            }

            let driftEndPoint = CGPoint(x: endPoint.x + driftOffset.x,
                                        y: endPoint.y + driftOffset.y)

            delegate.panEnded(at: endPoint, shouldDriftTo: driftEndPoint)
        default:
            break
        }
    }
}

fileprivate extension CGPoint {

    /**
     Returns a new CGPoint after applying a pan scrolling mode,
     i.e. zero-ing out the `x` OR `y` coordinate if required.
     */
    func applyPanScrollingMode(panScrollingMode: PanScrollingMode) -> CGPoint {
        switch panScrollingMode {
        case .horizontalAndVertical:
            return self
        case .horizontal:
            var point = self
            point.y = 0.0
            return point
        case .vertical:
            var point = self
            point.x = 0.0
            return point
        }
    }
}
