import UIKit

/// The RotateGestureHandler is responsible for all `rotate` related infrastructure
/// Tells the view to update itself when required
internal class RotateGestureHandler: GestureHandler {

    internal var initialAngle: CGFloat = 0.0
    internal weak var contextProvider: GestureContextProvider!

    // TODO: Inject the deceleration rate as part of a configuration structure
    internal let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue
    private let mapboxMap: MapboxMapProtocol
    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    internal init(for view: UIView,
                  withDelegate delegate: GestureHandlerDelegate,
                  andContextProvider contextProvider: GestureContextProvider,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        self.mapboxMap = mapboxMap
        self.cameraAnimationsManager = cameraAnimationsManager
        super.init(for: view, withDelegate: delegate)

        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(_:)))
        view.addGestureRecognizer(rotate)
        gestureRecognizer = rotate
        self.contextProvider = contextProvider
    }

    @objc internal func handleRotate(_ rotate: UIRotationGestureRecognizer) {

        cameraAnimationsManager.cancelAnimations()
        let anchor = rotate.location(in: view)

        // TODO: Handle simultaneous zoom & rotate gestures
        if rotate.state == .began {

            delegate.gestureBegan(for: .rotate)
            initialAngle = CGFloat((mapboxMap.cameraState.bearing * .pi) / 180.0 * -1)
        } else if rotate.state == .changed {

            let changedAngle = initialAngle + rotate.rotation
            delegate.rotationChanged(with: changedAngle,
                                     and: anchor,
                                     and: contextProvider?.fetchPinchScale() ?? 0.0)

        } else if rotate.state == .ended || rotate.state == .cancelled {

            // TODO: Handle "immediate" deceleration rates
            let finalAngle = (initialAngle + rotate.rotation) + (rotate.velocity * decelerationRate * 0.1)
            delegate.rotationEnded(with: finalAngle,
                                   and: anchor,
                                   with: contextProvider?.fetchPinchState() ??
                                              UIGestureRecognizer.State.possible)

        }
    }
}
