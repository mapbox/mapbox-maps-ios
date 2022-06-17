import CoreGraphics
import QuartzCore
import UIKit
internal final class PanZoomRotatePinchBehavior: PinchBehavior {
    private let initialCameraState: CameraState
    private let initialPinchMidpoint: CGPoint
    private let initialPinchAngle: CGFloat
    private let mapboxMap: MapboxMapProtocol
    var recognizer: UIGestureRecognizer!
    internal init(initialCameraState: CameraState,
                  initialPinchMidpoint: CGPoint,
                  initialPinchAngle: CGFloat,
                  mapboxMap: MapboxMapProtocol) {
        self.initialCameraState = initialCameraState
        self.initialPinchMidpoint = initialPinchMidpoint
        self.initialPinchAngle = initialPinchAngle
        self.mapboxMap = mapboxMap
    }

    private var previousPinchAngle: CGFloat?

    private var referenceAngle: CGFloat {
        return previousPinchAngle ?? initialPinchAngle
    }

    private var thresholdCrossed = false
    private var prevTime = CACurrentMediaTime()

    internal func update(pinchMidpoint: CGPoint,
                         pinchScale: CGFloat,
                         pinchAngle: CGFloat) {
        mapboxMap.performWithoutNotifying {
            mapboxMap.setCamera(
                to: CameraOptions(
                    center: initialCameraState.center,
                    zoom: initialCameraState.zoom,
                    bearing: initialCameraState.bearing))

            mapboxMap.dragStart(for: initialPinchMidpoint)
            let dragOptions = mapboxMap.dragCameraOptions(
                from: initialPinchMidpoint,
                to: pinchMidpoint)
            mapboxMap.setCamera(to: dragOptions)
            mapboxMap.dragEnd()
        }

        let zoomIncrement = log2(pinchScale)
        // flip the sign since the UIKit coordinate system is flipped
        // relative to the coordinate system used for bearing.
        let bearingIncrement = -initialPinchAngle
            .wrappedAngle(to: pinchAngle)
            .toDegrees()

        let foo = abs((pinchAngle - initialPinchAngle).toDegrees())
        let rotation = initialPinchAngle.toDegrees() - pinchAngle.toDegrees()
//        let bar: CGFloat
//        if abs(rotation) >= 3 || thresholdCrossed {
//            bar = bearingIncrement
//            thresholdCrossed = true
//        } else {
//            bar = 0
//        }
        let currTime = CACurrentMediaTime()
        let deltaSinceLast = abs(pinchAngle.toDegrees() - referenceAngle.toDegrees())
        let speed: CGFloat = deltaSinceLast / ((currTime - prevTime) * 1000)
        let deltaSinceStart = abs(initialPinchAngle.toDegrees() - pinchAngle.toDegrees())

        let bar: CGFloat
        if (speed < 0.04 ||
            speed > 0.07 && deltaSinceStart < 5 ||
            speed > 0.15 && deltaSinceStart < 7 ||
            speed > 0.5 && deltaSinceStart < 15) {
            bar = bearingIncrement
        } else {
            bar = 0
        }
print("speed \(speed), deltaSinceStart: \(deltaSinceStart), deltaSinseLast: \(deltaSinceLast)")
        let finalBearing = initialCameraState.bearing + CLLocationDirection(bar)
//        print("initial: \(initialPinchAngle.toDegrees()), current: \(pinchAngle.toDegrees()), diff: \(pinchAngle - initialPinchAngle), increment: \(rotation)")
        mapboxMap.setCamera(
            to: CameraOptions(
                anchor: pinchMidpoint,
                zoom: initialCameraState.zoom + zoomIncrement,
                bearing: finalBearing))

        previousPinchAngle = pinchAngle
    }
}
