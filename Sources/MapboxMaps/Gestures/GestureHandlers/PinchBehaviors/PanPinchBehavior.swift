internal final class PanPinchBehavior: PinchBehavior {
    private var currentPinchMidpoint: CGPoint
    private let mapboxMap: MapboxMapProtocol

    internal init(initialPinchMidpoint: CGPoint, mapboxMap: MapboxMapProtocol) {
        self.currentPinchMidpoint = initialPinchMidpoint
        self.mapboxMap = mapboxMap
    }

    internal func update(pinchMidpoint: CGPoint, pinchScale: CGFloat) {
        mapboxMap.dragStart(for: currentPinchMidpoint)
        let dragOptions = mapboxMap.dragCameraOptions(
            from: currentPinchMidpoint,
            to: pinchMidpoint)
        mapboxMap.setCamera(to: dragOptions)
        mapboxMap.dragEnd()

        currentPinchMidpoint = pinchMidpoint
    }
}
