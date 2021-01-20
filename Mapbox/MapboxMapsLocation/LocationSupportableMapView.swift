import Foundation
import CoreLocation
import MapboxMapsFoundation
import MapboxMapsStyle

public protocol LocationSupportableMapView: UIView {

    /// Matching the style property in `MapView`
    var style: Style! { get }

    /// Returns the screen coordinate for a given location coordinate (lat-long)
    func screenCoordinate(for locationCoordinate: CLLocationCoordinate2D) -> ScreenCoordinate

    /// Allows the `LocationSupportableMapView` to subscribe to a delegate
    func subscribeRenderFrameHandler(_ handler: @escaping (MapboxCoreMaps.Event) -> Void)

    /// Allows the `LocationSupportableMapView` to subscrive to a delegate function and handle style change events
    func subscribeStyleChangeHandler(_ handler: @escaping (MapboxCoreMaps.Event) -> Void)

    /// Gets meters per point at latitude for calculating accuracy ring
    func metersPerPointAtLatitude(latitude: CLLocationDegrees) -> CLLocationDistance

}
