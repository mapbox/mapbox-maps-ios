internal final class PanPinchBehavior: PinchBehavior {
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
        mapboxMap.performWithoutNotifying {
            mapboxMap.setCamera(to: CameraOptions(
                center: initialCameraState.center))
        }

        mapboxMap.dragStart(for: initialPinchMidpoint)
        let dragOptions = mapboxMap.dragCameraOptions(
            from: initialPinchMidpoint,
            to: pinchMidpoint)
        mapboxMap.setCamera(to: dragOptions)
        mapboxMap.dragEnd()
    }
}
