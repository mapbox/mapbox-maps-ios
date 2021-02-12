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
                                         action: #selector(self.handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        view.addGestureRecognizer(pan)
        self.gestureRecognizer = pan
        self.scrollMode = panScrollMode
    }

    // Handles the pan operation and calls the associated view
    @objc internal func handlePan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            self.delegate.gestureBegan(for: .pan)
        case .changed:
            let delta = pan.translation(in: pan.view).applyPanScrollingMode(panScrollingMode: scrollMode)
            self.delegate.panned(by: delta)
            pan.setTranslation(.zero, in: pan.view)
        case .ended, .cancelled:
            var velocity = pan.velocity(in: pan.view)

            if self.decelerationRate == 0.0 || (sqrt(pow(velocity.x, 2) + pow(velocity.y, 2)) < 100) {
                velocity = CGPoint.zero // Not enough velocity to overcome friction
            }

            if velocity != CGPoint.zero { // There is a potential drift after the gesture has ended
                let offset = CGPoint(x: velocity.x * decelerationRate,
                                     y: velocity.y * decelerationRate)
                                    .applyPanScrollingMode(panScrollingMode: scrollMode)

                self.delegate.panEnded(with: offset)
            }
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
