/// A proxy for access map interfaces on underlying Mapbox Map.
    @_documentation(visibility: public)
@_spi(Experimental)
@available(iOS 13.0, *)
public struct MapProxy {
    private var provider: MapViewProvider

    init(provider: MapViewProvider) {
        self.provider = provider
    }

    /// Extensive api for map camera animations.
    @_documentation(visibility: public)
    public var camera: CameraAnimationsManager? { provider.mapView?.camera }

    /// Manages styles, feature queries, and other map API.
    @_documentation(visibility: public)
    public var map: MapboxMap? { provider.mapView?.mapboxMap }

    /// Extensible API for driving the map camera.
    @_documentation(visibility: public)
    public var viewport: ViewportManager? { provider.mapView?.viewport }

    /// Handles location events on map.
    @_documentation(visibility: public)
    public var location: LocationManager? { provider.mapView?.location }
}
