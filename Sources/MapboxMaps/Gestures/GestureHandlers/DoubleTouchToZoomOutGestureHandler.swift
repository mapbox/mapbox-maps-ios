import UIKit

/// `DoubleTouchToZoomOutGestureHandler` updates the map camera in response
/// to single tap gestures with 2 touches
internal final class DoubleTouchToZoomOutGestureHandler: GestureHandler, FocusableGestureHandlerProtocol {
    internal var focalPoint: CGPoint?

    private let mapboxMap: MapboxMapProtocol
    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    internal init(gestureRecognizer: UITapGestureRecognizer,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.numberOfTouchesRequired = 2
        self.mapboxMap = mapboxMap
        self.cameraAnimationsManager = cameraAnimationsManager
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    @objc private func handleGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .recognized:
            guard let view = gestureRecognizer.view else { return }
            delegate?.gestureBegan(for: .doubleTouchToZoomOut)
            delegate?.gestureEnded(for: .doubleTouchToZoomOut, willAnimate: true)

            let anchor = focalPoint ?? gestureRecognizer.location(in: view)
            cameraAnimationsManager.ease(
                to: CameraOptions(anchor: anchor, zoom: mapboxMap.cameraState.zoom - 1),
                duration: 0.3,
                curve: .easeOut) { _ in
                    self.delegate?.animationEnded(for: .doubleTouchToZoomOut)
                }
        default:
            break
        }
    }
}
