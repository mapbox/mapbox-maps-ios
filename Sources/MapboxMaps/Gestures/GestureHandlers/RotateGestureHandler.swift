import UIKit

/// `RotateGestureHandler` updates the map camera in response to 2-touch rotate gestures
internal class RotateGestureHandler: GestureHandler {

    private var initialBearing: Double?

    internal init(view: UIView,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        let rotateGestureRecognizer = UIRotationGestureRecognizer()
        view.addGestureRecognizer(rotateGestureRecognizer)
        super.init(
            gestureRecognizer: rotateGestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        rotateGestureRecognizer.addTarget(self, action: #selector(handleRotate(_:)))
    }

    @objc internal func handleRotate(_ gestureRecognizer: UIRotationGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            cameraAnimationsManager.cancelAnimations()
            delegate?.gestureBegan(for: .rotate)
            initialBearing = mapboxMap.cameraState.bearing
        case .changed:
            guard let initialBearing = initialBearing else {
                return
            }
            cameraAnimationsManager.cancelAnimations()
            let rotationInDegrees = Double(gestureRecognizer.rotation * 180.0 / .pi * -1)
            mapboxMap.setCamera(
                to: CameraOptions(bearing: (initialBearing + rotationInDegrees).truncatingRemainder(dividingBy: 360.0)))
        case .ended, .cancelled:
            initialBearing = nil
        default:
            break
        }
    }
}
