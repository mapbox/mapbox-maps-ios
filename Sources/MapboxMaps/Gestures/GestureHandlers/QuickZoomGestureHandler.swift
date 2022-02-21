import UIKit

/// `QuickZoomGestureHandler` updates the map camera in response to double tap and drag gestures
internal final class QuickZoomGestureHandler: GestureHandler, FocusableGestureHandlerProtocol {
    private var initialLocation: CGPoint?
    private var initialZoom: CGFloat?
    internal var focalPoint: CGPoint?
    private let mapboxMap: MapboxMapProtocol
    private var initialFocalPoint: CGPoint?

    internal init(gestureRecognizer: UILongPressGestureRecognizer,
                  mapboxMap: MapboxMapProtocol) {
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.minimumPressDuration = 0
        self.mapboxMap = mapboxMap
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    @objc private func handleGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let view = gestureRecognizer.view else {
            return
        }
        let location = gestureRecognizer.location(in: view)
        switch gestureRecognizer.state {
        case .began:
            delegate?.gestureBegan(for: .quickZoom)
            initialLocation = location
            initialZoom = mapboxMap.cameraState.zoom
            initialFocalPoint = focalPoint
        case .changed:
            guard let initialLocation = initialLocation,
                  let initialZoom = initialZoom else {
                return
            }
            let distance = location.y - initialLocation.y
            // change by 1 zoom level per 75 points of translation
            let newZoom = initialZoom + distance / 75
            let anchor = initialFocalPoint ?? initialLocation
            mapboxMap.setCamera(to: CameraOptions(anchor: anchor, zoom: newZoom))
        case .ended, .cancelled:
            initialLocation = nil
            initialZoom = nil
            initialFocalPoint = nil
            delegate?.gestureEnded(for: .quickZoom, willAnimate: false)
        default:
            break
        }
    }
}
