import UIKit

/// The QuickZoomGestureHandler is responsible for handling all `quickZoom` related
/// infrastructure. The `quickZoom` gesture recognizer is triggered by
/// a tap gesture followed by a long press gesture.
internal class QuickZoomGestureHandler: GestureHandler {
    internal var quickZoomStart: CGFloat = 0.0
    internal var scale: CGFloat = 0.0

    override internal init(for view: UIView, withDelegate delegate: GestureHandlerDelegate) {
        super.init(for: view, withDelegate: delegate)

        let quickZoom = UILongPressGestureRecognizer(target: self, action: #selector(self.handleQuickZoom(_:)))
        quickZoom.numberOfTapsRequired = 1
        quickZoom.minimumPressDuration = 0
        self.gestureRecognizer = quickZoom
        view.addGestureRecognizer(quickZoom)
    }

    // Register the location of the touches in the view.
    @objc internal func handleQuickZoom(_ quickZoom: UILongPressGestureRecognizer) {
        guard let view = view else {
            return
        }

        let touchPoint = quickZoom.location(in: view)

        if quickZoom.state == .began {
            self.delegate.gestureBegan(for: .quickZoom)
            self.quickZoomStart = touchPoint.y
            self.scale = self.delegate.scaleForZoom()
        } else if quickZoom.state == .changed {
            let distance = touchPoint.y - self.quickZoomStart
            let bounds = view.bounds
            let anchor = CGPoint(x: bounds.midX, y: bounds.midY)

            var newScale = log2(self.scale + (distance / 75))

            if newScale.isNaN { newScale = 0 }

            self.delegate.quickZoomChanged(with: newScale, and: anchor)
        } else if quickZoom.state == .ended || quickZoom.state == .cancelled {
            self.delegate.quickZoomEnded()
        }
    }
}
