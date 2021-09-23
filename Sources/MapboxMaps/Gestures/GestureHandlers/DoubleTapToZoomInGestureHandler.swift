import UIKit

/// `DoubleTapToZoomInGestureHandler` updates the map camera in response
/// to double tap gestures with 1 touch
internal final class DoubleTapToZoomInGestureHandler: GestureHandler {

    internal init(gestureRecognizer: UITapGestureRecognizer,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        gestureRecognizer.numberOfTapsRequired = 2
        gestureRecognizer.numberOfTouchesRequired = 1
        super.init(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    @objc private func handleGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .recognized:
            cameraAnimationsManager.cancelAnimations()
            delegate?.gestureBegan(for: .doubleTapToZoomIn)
            delegate?.gestureEnded(for: .doubleTapToZoomIn, willAnimate: true)
            cameraAnimationsManager.ease(
                to: CameraOptions(zoom: mapboxMap.cameraState.zoom + 1),
                duration: 0.3,
                curve: .easeOut) { _ in
                    self.delegate?.driftEnded(for: .doubleTapToZoomIn)
                }
        default:
            break
        }
    }
}
