import UIKit

/// `QuickZoomGestureHandler` updates the map camera in response to double tap and drag gestures
internal class QuickZoomGestureHandler: GestureHandler {
    private var initialLocation: CGPoint?
    private var initialZoom: CGFloat?

    internal init(gestureRecognizer: UILongPressGestureRecognizer,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.minimumPressDuration = 0
        super.init(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    // Register the location of the touches in the view.
    @objc private func handleGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let view = gestureRecognizer.view else {
            return
        }
        let location = gestureRecognizer.location(in: view)
        switch gestureRecognizer.state {
        case .began:
            cameraAnimationsManager.cancelAnimations()
            delegate?.gestureBegan(for: .quickZoom)
            initialLocation = location
            initialZoom = mapboxMap.cameraState.zoom
        case .changed:
            guard let initialLocation = initialLocation,
                  let initialZoom = initialZoom else {
                return
            }
            let distance = location.y - initialLocation.y
            let bounds = view.bounds
            let anchor = CGPoint(x: bounds.midX, y: bounds.midY)
            var newZoom = initialZoom + distance / 75
            if newZoom.isNaN {
                newZoom = 0
            }
            let minZoom = CGFloat(mapboxMap.cameraBounds.minZoom)
            let maxZoom = CGFloat(mapboxMap.cameraBounds.maxZoom)
            newZoom = newZoom.clamped(to: minZoom...maxZoom)
            mapboxMap.setCamera(to: CameraOptions(anchor: anchor, zoom: newZoom))
        case .ended, .cancelled:
            initialLocation = nil
            initialZoom = nil
        default:
            break
        }
    }
}
