import UIKit

/// `PanGestureHandler` updates the map camera in response to a single-touch pan gesture
internal final class PanGestureHandler: GestureHandler {

    // The deceleration rate in points/ms^2
    internal var decelerationRate: CGFloat

    // Determines whether the horizontal translation, vertical
    // translation, or both are considered when panning
    internal var panScrollingMode: PanScrollingMode

    // The touch location in the gesture's view when the gesture began
    private var initialTouchLocation: CGPoint?

    // The camera state when the gesture began
    private var initialCameraState: CameraState?

    internal init(decelerationRate: CGFloat,
                  panScrollingMode: PanScrollingMode,
                  view: UIView,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        self.decelerationRate = decelerationRate
        self.panScrollingMode = panScrollingMode
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGestureRecognizer)
        super.init(
            gestureRecognizer: panGestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
    }

    // Handles the pan operation and calls the associated view
    @objc internal func handlePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let view = panGestureRecognizer.view else {
            return
        }

        let touchLocation = panGestureRecognizer.location(in: view)

        switch panGestureRecognizer.state {
        case .began:
            initialTouchLocation = touchLocation
            initialCameraState = mapboxMap.cameraState
            cameraAnimationsManager.cancelAnimations()
            delegate?.gestureBegan(for: .pan)
        case .changed:
            guard let initialTouchLocation = initialTouchLocation,
                  let initialCameraState = initialCameraState else {
                return
            }
            cameraAnimationsManager.cancelAnimations()

            // Reset the camera to its state when the gesture began
            mapboxMap.setCamera(to: CameraOptions(cameraState: initialCameraState))

            let clampedTouchLocation: CGPoint
            switch (panScrollingMode) {
            case .horizontal:
                clampedTouchLocation = CGPoint(x: touchLocation.x, y: initialTouchLocation.y)
            case .vertical:
                clampedTouchLocation = CGPoint(x: initialTouchLocation.x, y: touchLocation.y)
            case .horizontalAndVertical:
                clampedTouchLocation = touchLocation
            }

            // Execute the drag relative to the initial touch location
            mapboxMap.dragStart(for: initialTouchLocation)
            let dragCameraOptions = mapboxMap.dragCameraOptions(
                from: initialTouchLocation,
                to: clampedTouchLocation)
            mapboxMap.setCamera(to: dragCameraOptions)
            mapboxMap.dragEnd()
        case .ended, .cancelled:
            initialTouchLocation = nil
            initialCameraState = nil
        default:
            break
        }
    }
}
