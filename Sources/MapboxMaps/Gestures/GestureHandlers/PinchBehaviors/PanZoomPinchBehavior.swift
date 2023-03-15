import CoreGraphics

internal final class PanZoomPinchBehavior: PinchBehavior {
    private let initialCameraState: CameraState
    private var currentPinchMidpoint: CGPoint
    private let mapboxMap: MapboxMapProtocol

    internal init(initialCameraState: CameraState,
                  initialPinchMidpoint: CGPoint,
                  mapboxMap: MapboxMapProtocol) {
        self.initialCameraState = initialCameraState
        self.currentPinchMidpoint = initialPinchMidpoint
        self.mapboxMap = mapboxMap
    }

    internal func update(pinchMidpoint: CGPoint, pinchScale: CGFloat) {
        mapboxMap.performWithoutNotifying {
            mapboxMap.dragStart(for: currentPinchMidpoint)
            let dragOptions = mapboxMap.dragCameraOptions(
                from: currentPinchMidpoint,
                to: pinchMidpoint)
            mapboxMap.setCamera(to: dragOptions)
            mapboxMap.dragEnd()
        }

        let zoomIncrement = log2(pinchScale)
        mapboxMap.setCamera(to: CameraOptions(
            anchor: pinchMidpoint,
            zoom: initialCameraState.zoom + zoomIncrement))
        currentPinchMidpoint = pinchMidpoint
    }
}
