import UIKit

/// The RotateGestureHandler is responsible for all `rotate` related infrastructure
/// Tells the view to update itself when required
internal class RotateGestureHandler: GestureHandler {

    internal var initialAngle: CGFloat = 0.0
    internal weak var contextProvider: GestureContextProvider!
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
        if rotate.state == .began {
            delegate.gestureBegan(for: .rotate)
            initialAngle = CGFloat((mapboxMap.cameraState.bearing * .pi) / 180.0 * -1)
        } else if rotate.state == .changed {
            let changedAngle = initialAngle + rotate.rotation
            var changedAngleInDegrees = changedAngle * 180.0 / .pi * -1
            changedAngleInDegrees = changedAngleInDegrees.truncatingRemainder(dividingBy: 360.0)
            mapboxMap.setCamera(
                to: CameraOptions(bearing: CLLocationDirection(changedAngleInDegrees)))
        }
    }
}
