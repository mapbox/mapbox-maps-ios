import Foundation
import CoreLocation

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

#if canImport(MapboxMapsStyle)
import MapboxMapsStyle
#endif

public protocol LocationSupportableMapView: UIView {

    /// Returns the screen coordinate for a given location coordinate (lat-long)
    func point(for coordinate: CLLocationCoordinate2D) -> CGPoint

    /// Allows the `LocationSupportableMapView` to subscribe to a delegate
    func subscribeRenderFrameHandler(_ handler: @escaping (MapboxCoreMaps.Event) -> Void)

    /// Allows the `LocationSupportableMapView` to subscrive to a delegate function and handle style change events
    func subscribeStyleChangeHandler(_ handler: @escaping (MapboxCoreMaps.Event) -> Void)

    /// Gets meters per point at latitude for calculating accuracy ring
    func metersPerPointAtLatitude(latitude: CLLocationDegrees) -> CLLocationDistance
}
