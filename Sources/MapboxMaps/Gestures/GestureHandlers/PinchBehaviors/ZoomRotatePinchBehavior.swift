internal final class ZoomRotatePinchBehavior: PinchBehavior {
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
        let zoomIncrement = log2(pinchScale)

        // flip the sign since the UIKit coordinate system is flipped
        // relative to the coordinate system used for bearing.
        let bearingIncrement = -initialPinchAngle
            .wrappedAngle(to: pinchAngle)
            .toDegrees()
        mapboxMap.setCamera(to: CameraOptions(
            anchor: initialPinchMidpoint,
            zoom: initialCameraState.zoom + zoomIncrement,
            bearing: initialCameraState.bearing + CLLocationDirection(bearingIncrement)))
    }
}
