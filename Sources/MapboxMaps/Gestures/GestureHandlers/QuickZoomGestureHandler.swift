import UIKit

/// The QuickZoomGestureHandler is responsible for handling all `quickZoom` related
/// infrastructure. The `quickZoom` gesture recognizer is triggered by
/// a tap gesture followed by a long press gesture.
internal class QuickZoomGestureHandler: GestureHandler {
    private var quickZoomStart: CGFloat = 0.0
    private var scale: CGFloat = 0.0
    private let mapboxMap: MapboxMapProtocol

    init(for view: UIView, withDelegate delegate: GestureHandlerDelegate, mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
        super.init(for: view, withDelegate: delegate)

        let quickZoom = UILongPressGestureRecognizer(target: self, action: #selector(handleQuickZoom(_:)))
        quickZoom.numberOfTapsRequired = 1
        quickZoom.minimumPressDuration = 0
        gestureRecognizer = quickZoom
        view.addGestureRecognizer(quickZoom)
    }

    // Register the location of the touches in the view.
    @objc func handleQuickZoom(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let view = view else {
            return
        }

        let touchPoint = gestureRecognizer.location(in: view)

        if gestureRecognizer.state == .began {
            delegate.gestureBegan(for: .quickZoom)
            quickZoomStart = touchPoint.y
            scale = mapboxMap.cameraState.zoom
        } else if gestureRecognizer.state == .changed {
            let distance = touchPoint.y - quickZoomStart
            let bounds = view.bounds
            let anchor = CGPoint(x: bounds.midX, y: bounds.midY)

            var newScale = scale + distance / 75

            if newScale.isNaN { newScale = 0 }

            delegate.quickZoomChanged(with: newScale, and: anchor)
        } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            delegate.quickZoomEnded()
        }
    }
}
