/// A proxy for access map interfaces on underlying Mapbox Map.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
@available(iOS 13.0, *)
public struct MapProxy {
    private var provider: MapViewProvider

    init(provider: MapViewProvider) {
        self.provider = provider
    }

    /// Extensive api for map camera animations.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var camera: CameraAnimationsManager? { provider.mapView?.camera }

    /// Manages styles, feature queries, and other map API.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var map: MapboxMap? { provider.mapView?.mapboxMap }

    /// Extensible API for driving the map camera.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var viewport: ViewportManager? { provider.mapView?.viewport }

    /// Handles location events on map.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var location: LocationManager? { provider.mapView?.location }
}
