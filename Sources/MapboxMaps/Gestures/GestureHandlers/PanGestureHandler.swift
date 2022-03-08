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
    private var previousTouchLocation: CGPoint?

    /// The date when the most recent gesture changed event was handled
    private var lastChangedDate: Date?

    private let mapboxMap: MapboxMapProtocol

    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    /// Provides access to the current date in a way that can be mocked
    /// for unit testing
    private let dateProvider: DateProvider

    private var isPanning = false

    internal init(gestureRecognizer: UIPanGestureRecognizer,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol,
                  dateProvider: DateProvider) {
        gestureRecognizer.maximumNumberOfTouches = 1
        self.mapboxMap = mapboxMap
        self.cameraAnimationsManager = cameraAnimationsManager
        self.dateProvider = dateProvider
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    // Handle gesture events, treating `state == .changed && !isPanning` like `state == .began`,
    // and ignoring `state == .ended` and `state == .cancelled` when `!isPanning`
    @objc private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else {
            return
        }

        let touchLocation = gestureRecognizer.location(in: view)
        let velocity = gestureRecognizer.velocity(in: view)
        let state = gestureRecognizer.state

        switch state {
        case .began:
            handleGesture(withState: state, touchLocation: touchLocation, velocity: velocity)
        case .changed:
            if isPanning {
                handleGesture(withState: state, touchLocation: touchLocation, velocity: velocity)
            } else {
                handleGesture(withState: .began, touchLocation: touchLocation, velocity: velocity)
            }
        case .ended, .cancelled:
            if isPanning {
                handleGesture(withState: state, touchLocation: touchLocation, velocity: velocity)
            }
        default:
            break
        }
    }

    private func handleGesture(withState state: UIGestureRecognizer.State, touchLocation: CGPoint, velocity: CGPoint) {
        switch state {
        case .began:
            if !mapboxMap.pointIsAboveHorizon(touchLocation) {
                beginInteraction(withTouchLocation: touchLocation)
            }
        case .changed:
            guard let previousTouchLocation = previousTouchLocation else {
                return
            }
            lastChangedDate = dateProvider.now
            let clampedTouchLocation = touchLocation.clamped(to: previousTouchLocation, panMode: panMode)
            pan(from: previousTouchLocation, to: clampedTouchLocation)
            self.previousTouchLocation = clampedTouchLocation
        case .ended:
            // Only decelerate if the gesture ended quickly. Otherwise,
            // you get a deceleration in situations where you drag, then
            // hold the touch in place for several seconds, then release
            // it without further dragging. This specific time interval
            // is just the result of manual tuning.
            let decelerationTimeout: TimeInterval = 1.0 / 30.0
            guard !mapboxMap.pointIsAboveHorizon(touchLocation),
                  let lastChangedDate = lastChangedDate,
                  dateProvider.now.timeIntervalSince(lastChangedDate) < decelerationTimeout else {
                      endInteraction(willAnimate: false)
                      return
                  }
            // If the gesture is potentially ending near the horizon, continually reset the
            // touchLocation to 3/4 of the way to the bottom of the map while decelerating
            // to avoid simulated interaction with the more sensitvie area near the horizon.
            let height = mapboxMap.size.height
            let initialDecelerationLocation = CGPoint(
                x: touchLocation.x,
                y: max(touchLocation.y, 3 * height / 4))
            cameraAnimationsManager.decelerate(
                location: initialDecelerationLocation,
                velocity: velocity.clamped(to: .zero, panMode: panMode),
                decelerationFactor: decelerationFactor,
                locationChangeHandler: pan(from:to:),
                completion: { _ in
                    self.endAnimation()
                })
            endInteraction(willAnimate: true)
        case .cancelled:
            endInteraction(willAnimate: false)
        default:
            break
        }
    }

    private func beginInteraction(withTouchLocation touchLocation: CGPoint) {
        isPanning = true
        previousTouchLocation = touchLocation
        mapboxMap.dragStart(for: touchLocation)
        delegate?.gestureBegan(for: .pan)
    }

    private func endInteraction(willAnimate: Bool) {
        isPanning = false
        previousTouchLocation = nil
        lastChangedDate = nil
        if !willAnimate {
            mapboxMap.dragEnd()
        }
        delegate?.gestureEnded(for: .pan, willAnimate: willAnimate)
    }

    private func endAnimation() {
        mapboxMap.dragEnd()
        delegate?.animationEnded(for: .pan)
    }

    private func pan(from fromPoint: CGPoint, to toPoint: CGPoint) {
        mapboxMap.setCamera(
            to: mapboxMap.dragCameraOptions(
                from: fromPoint,
                to: toPoint))
    }
}

private extension CGPoint {
    func clamped(to point: CGPoint, panMode: PanMode) -> CGPoint {
        switch panMode {
        case .horizontal:
            return CGPoint(x: x, y: point.y)
        case .vertical:
            return CGPoint(x: point.x, y: y)
        case .horizontalAndVertical:
            return self
        }
    }
}
