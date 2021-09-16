import UIKit

/// `RotateGestureHandler` updates the map camera in response to 2-touch rotate gestures
internal final class RotateGestureHandler: GestureHandler, UIGestureRecognizerDelegate {

    private var initialBearing: Double?

    internal init(gestureRecognizer: UIRotationGestureRecognizer,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        super.init(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.gestureRecognizer === gestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer
    }

    @objc private func handleGesture(_ gestureRecognizer: UIRotationGestureRecognizer) {
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
