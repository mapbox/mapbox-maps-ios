import UIKit

/// `TapGestureHandler` updates the map camera in response
/// to double tap gestures with 1 or 2 touches
internal class TapGestureHandler: GestureHandler<UITapGestureRecognizer> {

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
            let gestureType: GestureType?
            let zoomDelta: CGFloat?
            switch gestureRecognizer.numberOfTouchesRequired {
            case 1:
                gestureType = .doubleTapToZoomIn
                zoomDelta = 1
            case 2:
                gestureType = .doubleTapToZoomOut
                zoomDelta = -1
            default:
                gestureType = nil
                zoomDelta = nil
            }
            guard let gestureType = gestureType,
                  let zoomDelta = zoomDelta else {
                return
            }
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
