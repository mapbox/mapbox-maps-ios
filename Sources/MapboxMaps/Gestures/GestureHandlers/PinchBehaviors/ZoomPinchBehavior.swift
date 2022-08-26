internal final class ZoomPinchBehavior: PinchBehavior {
    private let initialCameraState: CameraState
    private let initialPinchMidpoint: CGPoint
    private let mapboxMap: MapboxMapProtocol
    private let focalPoint: CGPoint?

    internal init(initialCameraState: CameraState,
                  initialPinchMidpoint: CGPoint,
                  focalPoint: CGPoint?,
                  mapboxMap: MapboxMapProtocol) {
        self.initialCameraState = initialCameraState
        self.initialPinchMidpoint = initialPinchMidpoint
        self.focalPoint = focalPoint
        self.mapboxMap = mapboxMap
    }

    internal func update(pinchMidpoint: CGPoint, pinchScale: CGFloat) {
        guard pinchScale > -1 else { return }
        let zoomIncrement = log2(1 + pinchScale)
        mapboxMap.setCamera(to: CameraOptions(
            anchor: focalPoint ?? pinchMidpoint,
            zoom: initialCameraState.zoom + zoomIncrement))
    }
}
