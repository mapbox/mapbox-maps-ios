import CoreGraphics
import QuartzCore
import UIKit
import CoreLocation
internal final class PanZoomRotatePinchBehavior: PinchBehavior {
    enum Mode {
        case zooming
        case rotating
    }
    private var initialCameraState: CameraState
    private let initialPinchMidpoint: CGPoint
    private let initialPinchAngle: CGFloat
    private let mapboxMap: MapboxMapProtocol
    private let simultaneousRotateAndPinchZoomEnabled: Bool
    var recognizer: UIGestureRecognizer!
    private var mode: Mode?
    internal init(initialCameraState: CameraState,
                  initialPinchMidpoint: CGPoint,
                  initialPinchAngle: CGFloat,
                  simultaneousRotateAndPinchZoomEnabled: Bool,
                  mapboxMap: MapboxMapProtocol) {
        self.initialCameraState = initialCameraState
        self.initialPinchMidpoint = initialPinchMidpoint
        self.initialPinchAngle = initialPinchAngle
        self.simultaneousRotateAndPinchZoomEnabled = simultaneousRotateAndPinchZoomEnabled
        self.mapboxMap = mapboxMap
    }

    private var previousPinchAngle: CGFloat?

    private var referenceAngle: CGFloat {
        return previousPinchAngle ?? initialPinchAngle
    }

    private var thresholdCrossed = false
    private var prevTime = CACurrentMediaTime()
    private var isRotating = false
    private var rotationStartAngle: CGFloat!

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

        print("speed \(speed), deltaSinceStart: \(deltaSinceStart), deltaSinseLast: \(deltaSinceLast)")
        let bar: CGFloat
        // adjust the responsiveness of a rotation gesture - the higher the speed, the bigger the threshold
        if !isRotating {
            if (speed < 0.04 ||
                speed > 0.07 && deltaSinceStart < 5 ||
                speed > 0.15 && deltaSinceStart < 7 ||
                speed > 0.5 && deltaSinceStart < 15) {
                //            print("kkk: ignoring rotation, speed: \(speed), delta: \(deltaSinceStart)")
                bar = 0
                rotationStartAngle = pinchAngle
            } else {
                isRotating = true
                bar = -(rotationStartAngle ?? initialPinchAngle)
                    .wrappedAngle(to: pinchAngle)
                    .toDegrees()
            }
        } else {
            bar = -(rotationStartAngle ?? initialPinchAngle)
                .wrappedAngle(to: pinchAngle)
                .toDegrees()
        }

        if !simultaneousRotateAndPinchZoomEnabled && mode == nil {
            mode = abs(zoomIncrement) > 0.15 ? .zooming : .rotating
        }
        let finalBearing = initialCameraState.bearing + (simultaneousRotateAndPinchZoomEnabled || mode == .rotating ? CLLocationDirection(bar) : 0)
//        print("initial: \(initialPinchAngle.toDegrees()), current: \(pinchAngle.toDegrees()), diff: \(pinchAngle - initialPinchAngle), increment: \(rotation)")
        mapboxMap.setCamera(
            to: CameraOptions(
                anchor: pinchMidpoint,
                zoom: initialCameraState.zoom + (simultaneousRotateAndPinchZoomEnabled || mode == .zooming ? zoomIncrement : 0)))
//                bearing: finalBearing))

        previousPinchAngle = pinchAngle
        prevTime = CACurrentMediaTime()
    }
}
