internal final class RotatePinchBehavior: PinchBehavior {
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
        // flip the sign since the UIKit coordinate system is flipped
        // relative to the coordinate system used for bearing.
        let bearingIncrement = -initialPinchAngle
            .wrappedAngle(to: pinchAngle)
            .toDegrees()
        mapboxMap.setCamera(to: CameraOptions(
            anchor: initialPinchMidpoint,
            bearing: initialCameraState.bearing + CLLocationDirection(bearingIncrement)))
    }
}
