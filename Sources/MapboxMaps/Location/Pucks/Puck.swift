#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

/// This protocol is used to help manipulate the different type of puck views we have
internal protocol Puck {

    /// Property that stores the current `PuckStyle` of the puck
    var puckStyle: PuckStyle { get set }

    /// Property that references the mapView that the puck should be draw
    var locationSupportableMapView: LocationSupportableMapView? { get }

    /// This function takes in a location object and will update the current `Puck` with that location
    func updateLocation(location: Location)

    /// This function will take in a new `PuckStyle` and change it accordingly
    func updateStyle(puckStyle: PuckStyle, location: Location)
}
