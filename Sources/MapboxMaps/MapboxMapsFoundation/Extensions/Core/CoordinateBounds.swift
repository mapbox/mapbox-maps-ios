import Foundation
import MapboxCoreMaps

// MARK: - CoordinateBounds

public extension CoordinateBounds {

    /// The northwest coordinate of an internal `CoordinateBounds` type.
    var northwest: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.northeast.latitude, longitude: self.southwest.longitude)
    }

    /// The northwest coordinate of an internal `CoordinateBounds` type.
    var southeast: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.southwest.latitude, longitude: self.northeast.longitude)
    }
}
