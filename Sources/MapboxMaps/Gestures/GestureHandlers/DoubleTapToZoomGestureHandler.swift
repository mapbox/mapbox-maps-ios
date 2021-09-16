import UIKit

/// `DoubleTapToZoomGestureHandler` updates the map camera in response
/// to double tap gestures with 1 or 2 touches
internal class DoubleTapToZoomGestureHandler: GestureHandler {

    private let zoomDelta: CGFloat
    private let gestureType: GestureType

    internal init(numberOfTouchesRequired: Int,
                  zoomDelta: CGFloat,
                  gestureRecognizer: UITapGestureRecognizer,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        precondition(zoomDelta.isFinite)
        precondition(!zoomDelta.isZero)
        gestureRecognizer.numberOfTapsRequired = 2
        gestureRecognizer.numberOfTouchesRequired = numberOfTouchesRequired
        self.zoomDelta = zoomDelta
        self.gestureType = zoomDelta > 0 ? .doubleTapToZoomIn : .doubleTapToZoomOut
        super.init(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    @objc private func handleGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .ended:
            cameraAnimationsManager.cancelAnimations()
            delegate?.gestureBegan(for: gestureType)
            _ = cameraAnimationsManager.ease(to: CameraOptions(zoom: mapboxMap.cameraState.zoom + zoomDelta),
                                             duration: 0.3,
                                             curve: .easeOut,
                                             completion: nil)
        default:
            break
        }
    }
}
