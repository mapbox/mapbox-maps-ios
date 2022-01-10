public final class ImmediateViewportTransition: ViewportTransition {
    private let mapboxMap: MapboxMapProtocol

    internal init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    public func run(from fromState: ViewportState?,
                    to toState: ViewportState,
                    completion: @escaping () -> Void) -> Cancelable {
        return toState.observeDataSource { [mapboxMap] cameraOptions in
            mapboxMap.setCamera(to: cameraOptions)
            completion()
            return false
        }
    }
}
