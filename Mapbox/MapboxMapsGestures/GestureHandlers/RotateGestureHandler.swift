import UIKit

/// The RotateGestureHandler is responsible for all `rotate` related infrastructure
/// Tells the view to update itself when required
internal class RotateGestureHandler: GestureHandler {

    internal var initialAngle: CGFloat = 0.0
    internal weak var contextProvider: GestureContextProvider!

    // TODO: Inject the deceleration rate as part of a configuration structure
    internal let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue

    internal init(for view: UIView,
                  withDelegate delegate: GestureHandlerDelegate,
                  andContextProvider contextProvider: GestureContextProvider) {
        super.init(for: view, withDelegate: delegate)

        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(self.handleRotate(_:)))
        view.addGestureRecognizer(rotate)
        self.gestureRecognizer = rotate
        self.contextProvider = contextProvider
    }

    @objc internal func handleRotate(_ rotate: UIRotationGestureRecognizer) {

        self.delegate.cancelGestureTransitions()
        let anchor = rotate.location(in: self.view)

        // TODO: Handle simultaneous zoom & rotate gestures
        if rotate.state == .began {

            self.delegate.gestureBegan(for: .rotate)
            self.initialAngle = self.delegate.rotationStartAngle()

        } else if rotate.state == .changed {

            let changedAngle = self.initialAngle + rotate.rotation
            self.delegate.rotationChanged(with: changedAngle,
                                          and: anchor,
                                          and: self.contextProvider?.fetchPinchScale() ?? 0.0)

        } else if rotate.state == .ended || rotate.state == .cancelled {

            // TODO: Handle "immediate" deceleration rates
            let finalAngle = (self.initialAngle + rotate.rotation) + (rotate.velocity * self.decelerationRate * 0.1)
            self.delegate.rotationEnded(with: finalAngle,
                                        and: anchor,
                                        with: self.contextProvider?.fetchPinchState() ??
                                              UIGestureRecognizer.State.possible)

        }
    }
}
