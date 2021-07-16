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

internal extension CoordinateBounds {
    func contains(_ coordinates: [CLLocationCoordinate2D]) -> Bool {
        let latitudeRange = southwest.latitude...northeast.latitude
        let longitudeRange = southwest.longitude...northeast.longitude

        for coordinate in coordinates {
            if latitudeRange.contains(coordinate.latitude) || longitudeRange.contains(coordinate.longitude) {
                return true
            }
        }
        return false
    }
}
