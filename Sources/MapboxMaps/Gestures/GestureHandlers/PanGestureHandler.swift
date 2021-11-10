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

    @objc private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else {
            return
        }

        let touchLocation = gestureRecognizer.location(in: view)

        switch gestureRecognizer.state {
        case .began:
            previousTouchLocation = touchLocation
            mapboxMap.dragStart(for: touchLocation)
            delegate?.gestureBegan(for: .pan)
        case .changed:
            guard let previousTouchLocation = previousTouchLocation else {
                return
            }
            lastChangedDate = dateProvider.now
            let clampedTouchLocation = clampTouchLocation(
                touchLocation,
                previousTouchLocation: previousTouchLocation)
            handleChange(
                withTouchLocation: clampedTouchLocation,
                previousTouchLocation: previousTouchLocation)
            self.previousTouchLocation = clampedTouchLocation
        case .ended:
            // Only decelerate if the gesture ended quickly. Otherwise,
            // you get a deceleration in situations where you drag, then
            // hold the touch in place for several seconds, then release
            // it without further dragging. This specific time interval
            // is just the result of manual tuning.
            let decelerationTimeout: TimeInterval = 1.0 / 30.0
            guard let lastChangedDate = lastChangedDate,
                  dateProvider.now.timeIntervalSince(lastChangedDate) < decelerationTimeout else {
                      previousTouchLocation = nil
                      lastChangedDate = nil
                      mapboxMap.dragEnd()
                      delegate?.gestureEnded(for: .pan, willAnimate: false)
                      return
                  }
            var previousDecelerationLocation = touchLocation
            cameraAnimationsManager.decelerate(
                location: touchLocation,
                velocity: gestureRecognizer.velocity(in: view),
                decelerationFactor: decelerationFactor,
                locationChangeHandler: { (touchLocation) in
                    let clampedTouchLocation = self.clampTouchLocation(
                        touchLocation,
                        previousTouchLocation: previousDecelerationLocation)
                    self.handleChange(
                        withTouchLocation: clampedTouchLocation,
                        previousTouchLocation: previousDecelerationLocation)
                    previousDecelerationLocation = clampedTouchLocation
                },
                completion: { [mapboxMap] in
                    mapboxMap.dragEnd()
                    self.delegate?.animationEnded(for: .pan)
                })
            self.previousTouchLocation = nil
            self.lastChangedDate = nil
            delegate?.gestureEnded(for: .pan, willAnimate: true)
        case .cancelled:
            // no deceleration
            previousTouchLocation = nil
            lastChangedDate = nil
            mapboxMap.dragEnd()
            delegate?.gestureEnded(for: .pan, willAnimate: false)
        default:
            break
        }
    }

    private func clampTouchLocation(_ touchLocation: CGPoint, previousTouchLocation: CGPoint) -> CGPoint {
        switch panMode {
        case .horizontal:
            return CGPoint(x: touchLocation.x, y: previousTouchLocation.y)
        case .vertical:
            return CGPoint(x: previousTouchLocation.x, y: touchLocation.y)
        case .horizontalAndVertical:
            return touchLocation
        }
    }

    private func handleChange(withTouchLocation touchLocation: CGPoint, previousTouchLocation: CGPoint) {
        mapboxMap.setCamera(
            to: mapboxMap.dragCameraOptions(
                from: previousTouchLocation,
                to: touchLocation))
    }
}
