import UIKit

internal protocol PanGestureHandlerProtocol: GestureHandler {
    var decelerationFactor: CGFloat { get set }

    var panMode: PanMode { get set }
}

/// `PanGestureHandler` updates the map camera in response to a single-touch pan gesture
internal final class PanGestureHandler: GestureHandler, PanGestureHandlerProtocol {

    /// A constant factor that influences how long a pan gesture takes to decelerate
    internal var decelerationFactor: CGFloat = UIScrollView.DecelerationRate.normal.rawValue

    /// A setting configures the direction in which the map is allowed to move
    /// during a pan gesture
    internal var panMode: PanMode = .horizontalAndVertical

    /// The touch location in the gesture's view when the gesture began
    private var initialTouchLocation: CGPoint?

    /// The camera state when the gesture began
    private var initialCameraState: CameraState?

    /// The date when the most recent gesture changed event was handled
    private var lastChangedDate: Date?

    /// Provides access to the current date in a way that can be mocked
    /// for unit testing
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
            guard let initialTouchLocation = initialTouchLocation,
                  let initialCameraState = initialCameraState else {
                return
            }
            lastChangedDate = dateProvider.now
            cameraAnimationsManager.cancelAnimations()
            handleChange(
                withTouchLocation: touchLocation,
                initialTouchLocation: initialTouchLocation,
                initialCameraState: initialCameraState)
        case .ended:
            // Only decelerate if the gesture ended quickly. Otherwise,
            // you get a deceleration in situations where you drag, then
            // hold the touch in place for several seconds, then release
            // it without further dragging. This specific time interval
            // is just the result of manual tuning.
            let decelerationTimeout: TimeInterval = 1.0 / 30.0
            guard let initialTouchLocation = initialTouchLocation,
                  let initialCameraState = initialCameraState,
                  let lastChangedDate = lastChangedDate,
                  dateProvider.now.timeIntervalSince(lastChangedDate) < decelerationTimeout else {
                delegate?.gestureEnded(for: .pan, willAnimate: false)
                return
            }
            cameraAnimationsManager.decelerate(
                location: touchLocation,
                velocity: gestureRecognizer.velocity(in: view),
                decelerationFactor: decelerationFactor,
                locationChangeHandler: { (touchLocation) in
                    // here we capture the initial state so that we can clear
                    // it immediately after starting the animation
                    self.handleChange(
                        withTouchLocation: touchLocation,
                        initialTouchLocation: initialTouchLocation,
                        initialCameraState: initialCameraState)
                },
                completion: {
                    self.delegate?.animationEnded(for: .pan)
                })
            self.initialTouchLocation = nil
            self.initialCameraState = nil
            self.lastChangedDate = nil
            delegate?.gestureEnded(for: .pan, willAnimate: true)
        case .cancelled:
            // no deceleration
            initialTouchLocation = nil
            initialCameraState = nil
            lastChangedDate = nil
            delegate?.gestureEnded(for: .pan, willAnimate: false)
        default:
            break
        }
    }

    private func handleChange(withTouchLocation touchLocation: CGPoint, initialTouchLocation: CGPoint, initialCameraState: CameraState) {
        // Reset the camera to its state when the gesture began
        mapboxMap.setCamera(to: CameraOptions(cameraState: initialCameraState))

        let clampedTouchLocation: CGPoint
        switch panMode {
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
