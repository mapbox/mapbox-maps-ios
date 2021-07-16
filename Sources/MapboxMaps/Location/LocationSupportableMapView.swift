import Foundation
import CoreLocation

internal protocol LocationSupportableMapView: UIView {

    /// Returns the screen coordinate for a given location coordinate (lat-long)
    func point(for coordinate: CLLocationCoordinate2D) -> CGPoint

    /// Gets meters per point at latitude for calculating accuracy ring
    func metersPerPointAtLatitude(latitude: CLLocationDegrees) -> CLLocationDistance
}
