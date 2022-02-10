/// A ``ViewportTransition`` implementation that transitions immediately without any animation.
///
/// Use ``Viewport/makeImmediateViewportTransition()`` to create instances of this class.
@_spi(Experimental) public final class ImmediateViewportTransition: ViewportTransition {
    private let mapboxMap: MapboxMapProtocol

    internal init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    /// :nodoc:
    /// See ``ViewportTransition/run(to:completion:)``.
    public func run(to toState: ViewportState,
                    completion: @escaping (Bool) -> Void) -> Cancelable {
        return toState.observeDataSource { [mapboxMap] cameraOptions in
            mapboxMap.setCamera(to: cameraOptions)
            completion(true)
            return false
        }
    }
}
