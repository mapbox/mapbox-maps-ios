import UIKit

/// `RotateGestureHandler` updates the map camera in response to 2-touch rotate gestures
internal class RotateGestureHandler: GestureHandler<UIRotationGestureRecognizer>, UIGestureRecognizerDelegate {

    private var initialBearing: Double?

    internal init(view: UIView,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        let rotationGestureRecognizer = UIRotationGestureRecognizer()
        view.addGestureRecognizer(rotationGestureRecognizer)
        super.init(
            gestureRecognizer: rotationGestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        rotationGestureRecognizer.delegate = self
        rotationGestureRecognizer.addTarget(self, action: #selector(handleRotate(_:)))
    }

    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.gestureRecognizer === gestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer
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
