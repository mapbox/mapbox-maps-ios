import UIKit

/// `QuickZoomGestureHandler` updates the map camera in response to double tap and drag gestures
internal final class QuickZoomGestureHandler: GestureHandler, ZoomGestureHandlerProtocol {
    internal var focalPoint: CGPoint?

    private var initialLocation: CGPoint?
    private var initialZoom: CGFloat?
    private let mapboxMap: MapboxMapProtocol

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
        case .changed:
            guard let initialLocation = initialLocation,
                  let initialZoom = initialZoom else {
                return
            }
            let distance = location.y - initialLocation.y
            // change by 1 zoom level per 75 points of translation
            let newZoom = initialZoom + distance / 75
            let anchor = focalPoint ?? initialLocation
            mapboxMap.setCamera(to: CameraOptions(anchor: anchor, zoom: newZoom))
        case .ended, .cancelled:
            initialLocation = nil
            initialZoom = nil
            delegate?.gestureEnded(for: .quickZoom, willAnimate: false)
        default:
            break
        }
    }
}
