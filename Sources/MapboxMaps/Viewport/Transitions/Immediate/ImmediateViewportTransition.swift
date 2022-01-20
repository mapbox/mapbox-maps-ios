@_spi(Experimental) public final class ImmediateViewportTransition: ViewportTransition {
    private let mapboxMap: MapboxMapProtocol

    internal init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    public func run(to toState: ViewportState,
                    completion: @escaping (Bool) -> Void) -> Cancelable {
        return toState.observeDataSource { [mapboxMap] cameraOptions in
            mapboxMap.setCamera(to: cameraOptions)
            completion(true)
            return false
        }
    }
}
