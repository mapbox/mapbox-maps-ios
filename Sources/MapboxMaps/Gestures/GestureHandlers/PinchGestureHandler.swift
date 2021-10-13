import UIKit
import CoreLocation

/// `PinchGestureHandler` updates the map camera in response to a 2-touch
/// gesture that may consist of translation, scaling, and rotation
internal final class PinchGestureHandler: GestureHandler {
    /// The midpoint of the touches in the gesture's view when the gesture began
    private var initialPinchMidpoint: CGPoint?

    /// The angle from touch location 0 to touch location 1 when the gesture began or unpaused
    private var initialPinchAngle: CGFloat?

    /// The camera center when the gesture began or unpaused
    private var initialCenter: CLLocationCoordinate2D?

    /// The camera zoom when the gesture began
    private var initialZoom: CGFloat?

    /// The camera bearing when the gesture began or unpaused
    private var initialBearing: CLLocationDirection?

    private let mapboxMap: MapboxMapProtocol

    /// Initialize the handler which creates the panGestureRecognizer and adds to the view
    internal init(gestureRecognizer: UIPinchGestureRecognizer,
                  mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    @objc private func handleGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard let view = gestureRecognizer.view else {
            return
        }
        let pinchMidpoint = gestureRecognizer.location(in: view)

        switch gestureRecognizer.state {
        case .began:
            initialPinchMidpoint = pinchMidpoint
            initialPinchAngle = pinchAngle(with: gestureRecognizer)
            initialCenter = mapboxMap.cameraState.center
            initialZoom = mapboxMap.cameraState.zoom
            initialBearing = mapboxMap.cameraState.bearing
            delegate?.gestureBegan(for: .pinch)
        case .changed:
            // UIPinchGestureRecognizer sends a .changed event when the number
            // of touches decreases from 2 to 1. If this happens, we pause our
            // gesture handling.
            //
            // if a second touch goes down again before the gesture ends, we
            // resume and re-capture the initial state (except for zoom since
            // UIPinchGestureRecognizer provides continuity of scale values)
            guard gestureRecognizer.numberOfTouches == 2 else {
                initialPinchMidpoint = nil
                initialPinchAngle = nil
                initialCenter = nil
                initialBearing = nil
                return
            }
            guard let initialZoom = initialZoom else {
                return
            }
            // Using explicit self to help out older versions of Xcode (pre-12.5) to figure out the scope of these variables here. Bug: https://bugs.swift.org/browse/SR-8669
            let pinchAngle = self.pinchAngle(with: gestureRecognizer)
            guard let initialPinchMidpoint = initialPinchMidpoint,
                  let initialPinchAngle = initialPinchAngle,
                  let initialCenter = initialCenter,
                  let initialBearing = initialBearing else {
                self.initialPinchMidpoint = pinchMidpoint
                self.initialPinchAngle = pinchAngle
                self.initialCenter = mapboxMap.cameraState.center
                self.initialBearing = mapboxMap.cameraState.bearing
                return
            }

            let zoomIncrement = log2(gestureRecognizer.scale)
            var cameraOptions = CameraOptions()
            cameraOptions.center = initialCenter
            cameraOptions.zoom = initialZoom
            cameraOptions.bearing = initialBearing

            mapboxMap.setCamera(to: cameraOptions)

            mapboxMap.dragStart(for: initialPinchMidpoint)
            let dragOptions = mapboxMap.dragCameraOptions(
                from: initialPinchMidpoint,
                to: pinchMidpoint)
            mapboxMap.setCamera(to: dragOptions)
            mapboxMap.dragEnd()

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
                    bearing: initialBearing + rotationInDegrees))
        case .ended, .cancelled:
            initialPinchMidpoint = nil
            initialPinchAngle = nil
            initialCenter = nil
            initialZoom = nil
            initialBearing = nil
            delegate?.gestureEnded(for: .pinch, willAnimate: false)
        default:
            break
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

    private func pinchAngle(with gestureRecognizer: UIPinchGestureRecognizer) -> CGFloat {
        // we guard for this at the call site
        let view = gestureRecognizer.view!
        let pinchPoint0 = gestureRecognizer.location(ofTouch: 0, in: view)
        let pinchPoint1 = gestureRecognizer.location(ofTouch: 1, in: view)
        return angleOfLine(from: pinchPoint0, to: pinchPoint1)
    }
}
