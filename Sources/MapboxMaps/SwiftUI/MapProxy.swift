import SwiftUI

/// A proxy for access map interfaces on underlying Mapbox Map.
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
    @available(*, deprecated, message: "Use Map(viewport:) initializer instead.")
    public var viewport: ViewportManager? { provider.mapView?.viewport }

    /// Handles location events on map.
    public var location: LocationManager? { provider.mapView?.location }

    /// Captures the snapshot of the displayed Map.
    ///
    /// - Parameters:
    ///   - includeOverlays: Whether to show ornaments (scale bar, compass, attribution, etc.) or any other custom subviews on the resulting image.
    public func captureSnapshot(includeOverlays: Bool = false) -> UIImage? {
        guard let uiImage = try? provider.mapView?.snapshot(includeOverlays: includeOverlays) else {
            return nil
        }
        return uiImage
    }
}
