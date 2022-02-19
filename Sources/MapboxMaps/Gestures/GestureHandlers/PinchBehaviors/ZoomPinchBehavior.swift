internal final class ZoomPinchBehavior: PinchBehavior {
    private let initialCameraState: CameraState
    private let initialPinchMidpoint: CGPoint
    private let mapboxMap: MapboxMapProtocol

    internal init(initialCameraState: CameraState,
                  initialPinchMidpoint: CGPoint,
                  mapboxMap: MapboxMapProtocol) {
        self.initialCameraState = initialCameraState
        self.initialPinchMidpoint = initialPinchMidpoint
        self.mapboxMap = mapboxMap
    }

    internal func update(pinchMidpoint: CGPoint,
                         pinchScale: CGFloat,
                         pinchAngle: CGFloat) {
        let zoomIncrement = log2(pinchScale)
        mapboxMap.setCamera(to: CameraOptions(
            anchor: initialPinchMidpoint,
            zoom: initialCameraState.zoom + zoomIncrement))
    }
}
