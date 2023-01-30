import MapboxMaps

/// A proxy for access map interfaces of child MapboxView.
@_spi(Experimental)
@available(iOS 13.0, *)
public struct MapProxy {
    private var provider: MapViewProvider

    init(provider: MapViewProvider) {
        self.provider = provider
    }

    /// Extensive api for map camera animations.
    public var camera: CameraAnimationsManager? { provider.mapView?.camera }

    /// Manages styles, feature queries, and other map API.
    public var map: MapboxMap? { provider.mapView?.mapboxMap }

    /// Extensible API for driving the map camera.
    public var viewport: Viewport? { provider.mapView?.viewport }

    /// Handles location events on map.
    public var location: LocationManager? { provider.mapView?.location }
}
