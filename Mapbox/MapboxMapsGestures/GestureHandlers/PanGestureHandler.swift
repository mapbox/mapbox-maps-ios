import UIKit

/// The PanGestureHandler is responsible for all `pan` related infrastructure
/// Tells the view to update itself when required
internal class PanGestureHandler: GestureHandler {

    internal let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue
    internal var scrollMode = PanScrollingMode.horizontalAndVertical
    internal var cameraManager: CameraManager?

    // Initialize the handler which creates the panGestureRecognizer and adds to the view
    internal init(for view: UIView, withDelegate delegate: GestureHandlerDelegate, panScrollMode: PanScrollingMode, cameraManager: CameraManager?) {
        super.init(for: view, withDelegate: delegate)
        let pan = UIPanGestureRecognizer(target: self,
                                         action: #selector(self.handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        view.addGestureRecognizer(pan)
        self.gestureRecognizer = pan
        self.scrollMode = panScrollMode
        self.cameraManager = cameraManager
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
        case .ended:
            //swiftlint:disable no_fallthrough_only
            fallthrough
        case .cancelled:
            let velocity = pan.velocity(in: pan.view)

            // If there is no velocity, then quit the gesture and don't drift
            if velocity == CGPoint.zero {
                break
            }

            /// Pitched camera's will have a larger velocity when panning and therefore the offset will need a multiplier applied to it
            /// based on the current pitch value of the mapView
            if let cameraManager = self.cameraManager,
               let pitch = cameraManager.mapView?.pitch {
                var pitchFactor = pitch

                if pitch == cameraManager.mapCameraOptions.minimumPitch {
                    pitchFactor = 0.0
                } else {
                    pitchFactor /= 10.0
                }

                pitchFactor += 1.5

                var offset = CGPoint(x: velocity.x / pitchFactor * (decelerationRate / 4),
                                     y: velocity.y / pitchFactor * (decelerationRate / 4))
                offset = offset.applyPanScrollingMode(panScrollingMode: scrollMode)

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
