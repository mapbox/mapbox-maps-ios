import UIKit

/// `PinchGestureHandler` updates the map camera in response to a 2-touch
/// gesture that may consist of translation, scaling, and rotation
internal final class PinchGestureHandlerImpl2: PinchGestureHandlerImpl {
    /// Whether pinch gesture can rotate map or not
    internal var rotateEnabled: Bool = true

    /// The midpoint of the touches in the gesture's view when the gesture began
    private var previousPinchMidpoint: CGPoint?

    /// The angle from touch location 0 to touch location 1 when the gesture began or unpaused
    private var initialPinchAngle: CGFloat?

    /// The camera zoom when the gesture began
    private var initialZoom: CGFloat?

    /// The camera bearing when the gesture began or unpaused
    private var initialBearing: CLLocationDirection?

    /// The rotateEnabled setting when the gesture began
    private var initialRotateEnabled: Bool?

    private let mapboxMap: MapboxMapProtocol

    private var isDragging = false

    private var gestureBegan = false

    internal weak var delegate: GestureHandlerDelegate?

    /// Initialize the handler which creates the panGestureRecognizer and adds to the view
    internal init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    // swiftlint:disable:next cyclomatic_complexity
    internal func handleGesture(_ gestureRecognizer: UIPinchGestureRecognizer, state: UIGestureRecognizer.State) {
        guard let view = gestureRecognizer.view else {
            return
        }
        let pinchMidpoint = gestureRecognizer.location(in: view)

        switch state {
        case .began:
            guard gestureRecognizer.numberOfTouches == 2 else {
                return
            }
            startDragging(with: pinchMidpoint)
            previousPinchMidpoint = pinchMidpoint
            initialPinchAngle = pinchAngleForGestureBegan(with: gestureRecognizer)
            initialZoom = mapboxMap.cameraState.zoom
            initialBearing = mapboxMap.cameraState.bearing
            initialRotateEnabled = rotateEnabled
            gestureBegan = true
            delegate?.gestureBegan(for: .pinch)
        case .changed:
            // UIPinchGestureRecognizer sends a .changed event when the number
            // of touches decreases from 2 to 1. If this happens, we pause our
            // gesture handling.
            guard gestureRecognizer.numberOfTouches == 2 else {
                previousPinchMidpoint = nil
                initialPinchAngle = nil
                initialBearing = nil
                stopDraggingIfNeeded()
                return
            }
            guard let initialZoom = initialZoom,
                  let initialRotateEnabled = initialRotateEnabled else {
                return
            }

            // if a second touch goes down again before the gesture ends, we
            // resume and re-capture the initial state (except for zoom since
            // UIPinchGestureRecognizer provides continuity of scale values)
            let pinchAngle = pinchAngleForGestureChanged(with: gestureRecognizer)
            guard let previousPinchMidpoint = previousPinchMidpoint,
                  let initialPinchAngle = initialPinchAngle,
                  let initialBearing = initialBearing else {
                      startDragging(with: pinchMidpoint)
                      self.previousPinchMidpoint = pinchMidpoint
                      self.initialPinchAngle = pinchAngle
                      self.initialBearing = mapboxMap.cameraState.bearing
                return
            }

            let zoomIncrement = log2(gestureRecognizer.scale)

            mapboxMap.setCamera(to: mapboxMap.dragCameraOptions(
                from: previousPinchMidpoint,
                to: pinchMidpoint))
            self.previousPinchMidpoint = pinchMidpoint

            // the two angles will always be in the range [0, 2pi)
            // so the resulting rotation will be in the range (-2pi, 2pi)
            var rotation = pinchAngle - initialPinchAngle
            // if the rotation is negative, add 2pi so that the final
            // result is in the range [0, 2pi)
            if rotation < 0 {
                rotation += 2 * .pi
            }
            // convert from radians to degrees and flip the sign since
            // the iOS coordinate system is flipped relative to the
            // coordinate system used for bearing in the map.
            let rotationInDegrees = Double(rotation * 180.0 / .pi * -1)

            mapboxMap.setCamera(
                to: CameraOptions(
                    anchor: pinchMidpoint,
                    zoom: initialZoom + zoomIncrement,
                    bearing: initialRotateEnabled ? (initialBearing + rotationInDegrees) : nil))
        case .ended, .cancelled:
            previousPinchMidpoint = nil
            initialPinchAngle = nil
            initialZoom = nil
            initialBearing = nil
            initialRotateEnabled = nil
            stopDraggingIfNeeded()
            if gestureBegan {
                delegate?.gestureEnded(for: .pinch, willAnimate: false)
            }
            gestureBegan = false
        default:
            break
        }
    }

    private func startDragging(with point: CGPoint) {
        precondition(!isDragging)
        isDragging = true
        mapboxMap.dragStart(for: point)
    }

    private func stopDraggingIfNeeded() {
        if isDragging {
            isDragging = false
            mapboxMap.dragEnd()
        }
    }

    /// Returns the angle in radians in the range [0, 2pi)
    private func angleOfLine(from point0: CGPoint, to point1: CGPoint) -> CGFloat {
        var angle = atan2(point1.y - point0.y, point1.x - point0.x)
        if angle < 0 {
            angle += 2 * .pi
        }
        return angle
    }

    // this method is added to help diagnose a crash in pinchAngle. if the crash continues to happen,
    // we'll be able to tell which invocation of pinchAngle is responsible.
    private func pinchAngleForGestureBegan(with gestureRecognizer: UIPinchGestureRecognizer) -> CGFloat {
        return pinchAngle(with: gestureRecognizer)
    }

    // this method is added to help diagnose a crash in pinchAngle. if the crash continues to happen,
    // we'll be able to tell which invocation of pinchAngle is responsible.
    private func pinchAngleForGestureChanged(with gestureRecognizer: UIPinchGestureRecognizer) -> CGFloat {
        return pinchAngle(with: gestureRecognizer)
    }

    private func pinchAngle(with gestureRecognizer: UIPinchGestureRecognizer) -> CGFloat {
        // we guard for this at the call site
        let view = gestureRecognizer.view!
        let pinchPoint0 = gestureRecognizer.location(ofTouch: 0, in: view)
        let pinchPoint1 = gestureRecognizer.location(ofTouch: 1, in: view)
        return angleOfLine(from: pinchPoint0, to: pinchPoint1)
    }
}
