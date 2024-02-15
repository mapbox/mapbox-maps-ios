import UIKit

internal protocol PanGestureHandlerProtocol: GestureHandler {
    var decelerationFactor: CGFloat { get set }

    var panMode: PanMode { get set }

    var multiFingerPanEnabled: Bool { get set }
}

/// `PanGestureHandler` updates the map camera in response to a pan gesture
internal final class PanGestureHandler: GestureHandler, PanGestureHandlerProtocol {

    /// A constant factor that influences how long a pan gesture takes to decelerate
    internal var decelerationFactor: CGFloat = UIScrollView.DecelerationRate.normal.rawValue

    /// A setting configures the direction in which the map is allowed to move
    /// during a pan gesture
    internal var panMode: PanMode = .horizontalAndVertical

    internal var multiFingerPanEnabled: Bool = true {
        didSet {
            (gestureRecognizer as? UIPanGestureRecognizer)?.maximumNumberOfTouches = multiFingerPanEnabled ? .max : 1
        }
    }

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
    private var numberOfTouches = 0

    internal init(gestureRecognizer: UIPanGestureRecognizer,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol,
                  dateProvider: DateProvider) {
        self.mapboxMap = mapboxMap
        self.cameraAnimationsManager = cameraAnimationsManager
        self.dateProvider = dateProvider
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    // Handle gesture events, treating `state == .changed && !isPanning` like `state == .began`,
    // and ignoring `state == .ended` and `state == .cancelled` when `!isPanning`
    @objc private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else {
            return
        }

        let touchLocation = gestureRecognizer.centroid(in: view)
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
            numberOfTouches = gestureRecognizer.numberOfTouches
        case .changed:
            // update reference(previous) touch location when number of touches changes,
            // so the map doesn't jump suddenly
            if numberOfTouches != gestureRecognizer.numberOfTouches {
                previousTouchLocation = touchLocation
                numberOfTouches = gestureRecognizer.numberOfTouches
                return
            }

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
        delegate?.gestureBegan(for: .pan)
    }

    private func endInteraction(willAnimate: Bool) {
        isPanning = false
        previousTouchLocation = nil
        lastChangedDate = nil
        delegate?.gestureEnded(for: .pan, willAnimate: willAnimate)
    }

    private func endAnimation() {
        delegate?.animationEnded(for: .pan)
    }

    private func pan(from fromPoint: CGPoint, to toPoint: CGPoint) {
        mapboxMap.setCamera(
            to: mapboxMap.dragCameraOptions(
                from: fromPoint,
                to: toPoint))
    }
}

extension PanGestureHandler: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard gestureRecognizer === self.gestureRecognizer else { return false }
        /// The map can be used inside a scroll view which has it's own `PanGestureRecognizer` and they should be mutually exclusive.
        /// This will introduce problems for client who are going to implement custom `DragGesture` in SwiftUI, but it's considered as rare case.
        /// That's said`gestureRecognizer.attachedToSameView` check is skipped here.

        switch otherGestureRecognizer {
        case is UIRotationGestureRecognizer:
            return true
        case is UIPinchGestureRecognizer:
            return true
        default:
            return false
        }
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

internal extension UIPanGestureRecognizer {
    func centroid(in view: UIView?) -> CGPoint {
        let numberOfTouches = self.numberOfTouches

        let sum = (0..<numberOfTouches)
            .map { index in location(ofTouch: index, in: view) }
            .reduce(into: CGPoint()) { partialResult, location in
                partialResult.x += location.x
                partialResult.y += location.y
            }
        guard numberOfTouches > 0 else {
            return location(in: view)
        }
        return CGPoint(x: sum.x / CGFloat(numberOfTouches), y: sum.y / CGFloat(numberOfTouches))
    }
}
