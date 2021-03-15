import Foundation
import MapboxCoreMaps

// MARK: - CoordinateBounds

public extension CoordinateBounds {

    /// The northwest coordinate of an internal `CoordinateBounds` type.
    var northwest: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: northeast.latitude, longitude: southwest.longitude)
    }

    /// The northwest coordinate of an internal `CoordinateBounds` type.
    var southeast: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: southwest.latitude, longitude: northeast.longitude)
    }
}
