import UIKit

/// `QuickZoomGestureHandler` updates the map camera in response to double tap and drag gestures
internal class QuickZoomGestureHandler: GestureHandler {
    private var initialLocation: CGPoint?
    private var initialZoom: CGFloat?

    init(view: UIView,
         mapboxMap: MapboxMapProtocol,
         cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        let quickZoom = UILongPressGestureRecognizer()
        quickZoom.numberOfTapsRequired = 1
        quickZoom.minimumPressDuration = 0
        view.addGestureRecognizer(quickZoom)
        super.init(
            gestureRecognizer: quickZoom,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        quickZoom.addTarget(self, action: #selector(handleQuickZoom(_:)))
    }

    // Register the location of the touches in the view.
    @objc func handleQuickZoom(_ gestureRecognizer: UILongPressGestureRecognizer) {
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
