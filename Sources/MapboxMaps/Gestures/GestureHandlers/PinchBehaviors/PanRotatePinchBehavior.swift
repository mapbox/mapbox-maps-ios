import CoreGraphics

internal final class PanRotatePinchBehavior: PinchBehavior {
    private let initialCameraState: CameraState
    private let initialPinchMidpoint: CGPoint
    private let initialPinchAngle: CGFloat
    private let mapboxMap: MapboxMapProtocol

    internal init(initialCameraState: CameraState,
                  initialPinchMidpoint: CGPoint,
                  initialPinchAngle: CGFloat,
                  mapboxMap: MapboxMapProtocol) {
        self.initialCameraState = initialCameraState
        self.initialPinchMidpoint = initialPinchMidpoint
        self.initialPinchAngle = initialPinchAngle
        self.mapboxMap = mapboxMap
    }

    internal func update(pinchMidpoint: CGPoint,
                         pinchScale: CGFloat,
                         pinchAngle: CGFloat) {
        mapboxMap.performWithoutNotifying {
            mapboxMap.setCamera(
                to: CameraOptions(
                    center: initialCameraState.center,
                    bearing: initialCameraState.bearing))

            mapboxMap.dragStart(for: initialPinchMidpoint)
            let dragOptions = mapboxMap.dragCameraOptions(
                from: initialPinchMidpoint,
                to: pinchMidpoint)
            mapboxMap.setCamera(to: dragOptions)
            mapboxMap.dragEnd()
        }

        // flip the sign since the UIKit coordinate system is flipped
        // relative to the coordinate system used for bearing.
        let bearingIncrement = -initialPinchAngle
            .wrappedAngle(to: pinchAngle)
            .toDegrees()
        mapboxMap.setCamera(to: CameraOptions(
            anchor: pinchMidpoint,
            bearing: initialCameraState.bearing + CLLocationDirection(bearingIncrement)))
    }
}
