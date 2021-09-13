import UIKit

/// `TapGestureHandler` updates the map camera in response
/// to double tap gestures with 1 or 2 touches
internal class TapGestureHandler: GestureHandler {

    internal required init(numberOfTouchesRequired: Int,
                           view: UIView,
                           mapboxMap: MapboxMapProtocol,
                           cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        precondition((1...2).contains(numberOfTouchesRequired))
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = 2
        tapGestureRecognizer.numberOfTouchesRequired = numberOfTouchesRequired
        view.addGestureRecognizer(tapGestureRecognizer)
        super.init(
            gestureRecognizer: tapGestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap(_:)))
    }

    // Calls view to process the tap gesture
    @objc internal func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .ended:
            guard gestureRecognizer.numberOfTapsRequired == 2 else {
                return
            }
            let zoomDelta: CGFloat?
            switch gestureRecognizer.numberOfTouchesRequired {
            case 1:
                // Double tapping with one finger will cause the map to zoom out by 1 level
                zoomDelta = 1
            case 2:
                // Double tapping with two fingers will cause the map to zoom in by 1 level
                zoomDelta = -1
            default:
                zoomDelta = nil
            }
            guard let zoomDelta = zoomDelta else {
                return
            }
            cameraAnimationsManager.cancelAnimations()
            delegate?.gestureBegan(for: .tap(numberOfTouches: gestureRecognizer.numberOfTouchesRequired))
            _ = cameraAnimationsManager.ease(to: CameraOptions(zoom: mapboxMap.cameraState.zoom + zoomDelta),
                                             duration: 0.3,
                                             curve: .easeOut,
                                             completion: nil)
        default:
            break
        }
    }
}
