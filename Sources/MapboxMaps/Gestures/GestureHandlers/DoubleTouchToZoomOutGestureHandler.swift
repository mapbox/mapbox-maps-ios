import UIKit

/// `DoubleTouchToZoomOutGestureHandler` updates the map camera in response
/// to single tap gestures with 2 touches
internal final class DoubleTouchToZoomOutGestureHandler: GestureHandler {

    internal init(gestureRecognizer: UITapGestureRecognizer,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.numberOfTouchesRequired = 2
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
            delegate?.gestureBegan(for: .doubleTouchToZoomOut)
            delegate?.gestureEnded(for: .doubleTouchToZoomOut, willAnimate: true)
            cameraAnimationsManager.ease(
                to: CameraOptions(zoom: mapboxMap.cameraState.zoom - 1),
                duration: 0.3,
                curve: .easeOut) { _ in
                    self.delegate?.animationEnded(for: .doubleTouchToZoomOut)
                }
        default:
            break
        }
    }
}
