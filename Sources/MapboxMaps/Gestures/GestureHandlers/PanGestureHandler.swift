import UIKit

/// `PanGestureHandler` updates the map camera in response to a single-touch pan gesture
internal final class PanGestureHandler: GestureHandler {
    // The touch location in the gesture's view when the gesture began
    private var initialTouchLocation: CGPoint?

    // The camera state when the gesture began
    private var initialCameraState: CameraState?

    private var lastChangedDate: Date?

    private let dateProvider: DateProvider

    internal init(gestureRecognizer: UIPanGestureRecognizer,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol,
                  dateProvider: DateProvider) {
        gestureRecognizer.maximumNumberOfTouches = 1
        self.dateProvider = dateProvider
        super.init(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    //swiftlint:disable cyclomatic_complexity
    @objc private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else {
            return
        }

        let touchLocation = gestureRecognizer.location(in: view)

        switch gestureRecognizer.state {
        case .began:
            initialTouchLocation = touchLocation
            initialCameraState = mapboxMap.cameraState
            cameraAnimationsManager.cancelAnimations()
            delegate?.gestureBegan(for: .pan)
        case .changed:
            lastChangedDate = dateProvider.now
            cameraAnimationsManager.cancelAnimations()
            handleChange(withTouchLocation: touchLocation)
        case .ended:
            // decelerate
            guard let lastChangedDate = lastChangedDate,
                  // if it's been more than 2 frames at 60 Hz since the last change, don't drift
                  dateProvider.now.timeIntervalSince(lastChangedDate) < 2.0 / 60.0,
                  let decelerationRate = delegate?.decelerationRate else {
                return
            }
            cameraAnimationsManager.decelerate(
                location: touchLocation,
                velocity: gestureRecognizer.velocity(in: view),
                decelerationRate: decelerationRate,
                locationChangeHandler: handleChange(withTouchLocation:),
                completion: {
                    self.initialTouchLocation = nil
                    self.initialCameraState = nil
                    self.lastChangedDate = nil
                })
        case .cancelled:
            // no deceleration
            initialTouchLocation = nil
            initialCameraState = nil
            lastChangedDate = nil
        default:
            break
        }
    }

    private func handleChange(withTouchLocation touchLocation: CGPoint) {
        guard let initialTouchLocation = initialTouchLocation,
              let initialCameraState = initialCameraState,
              let panScrollingMode = delegate?.panScrollingMode else {
            return
        }

        // Reset the camera to its state when the gesture began
        mapboxMap.setCamera(to: CameraOptions(cameraState: initialCameraState))

        let clampedTouchLocation: CGPoint
        switch panScrollingMode {
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
    }
}
