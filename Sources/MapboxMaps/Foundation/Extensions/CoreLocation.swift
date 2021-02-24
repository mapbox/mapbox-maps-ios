import Foundation
import CoreLocation
import CoreGraphics
import MapboxCoreMaps

// MARK: - CLLocationCoordinate2D
public extension CLLocationCoordinate2D {

    /// Converts a `CLLocationCoordinate` to a `CLLocation`.
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    /// Returns a new `CLLocationCoordinate` value with a new latitude constrained within 360 degrees.
    func wrap() -> CLLocationCoordinate2D {
        /**
         mbgl::geo.hpp equivalent:

         void wrap() {
             lon = util::wrap(lon, -util::LONGITUDE_MAX, util::LONGITUDE_MAX);
         }
         */

        let wrappedLongitude = Utils.wrap(forValue: self.longitude, min: -180.0, max: 180.0)

        return CLLocationCoordinate2D(latitude: self.latitude, longitude: wrappedLongitude)
    }

    /// Returns a new `CLLocationCoordinate` where the longitude is wrapped if
    /// the distance from start to end longitudes is between a half and full
    /// world, ensuring that the shortest path is taken.
    /// - Parameter end: The coordinate to possibly wrap, if needed.
    func unwrapForShortestPath(_ end: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let delta = fabs(end.longitude - longitude)

        if delta <= 180.0 || delta >= 360 {
            return self
        }

        var lon = longitude

        if longitude > 0 && end.longitude < 0 {
            lon -= 360.0
        } else if longitude < 0 && end.longitude > 0 {
            lon += 360.0
        }

        return CLLocationCoordinate2D(latitude: latitude, longitude: lon)
    }

    /// Convert a `CLLocationCoordinate` to a `NSValue` which wraps a `CGPoint`.
    internal func toValue() -> NSValue {
        return NSValue(cgPoint: CGPoint(x: self.latitude, y: self.longitude))
    }

    /// Convert an array of `CLLocationCoordinate`s to an array of `NSValue`s that wrap a `CGPoint`.
    internal static func convertToValues(from coordinates: [CLLocationCoordinate2D]) -> [NSValue] {
        return coordinates.map { (coordinate) -> NSValue in
            return NSValue(cgPoint: CGPoint(x: coordinate.latitude, y: coordinate.longitude))
        }
    }
}

// MARK: - CLLocationDirection
public extension CLLocationDirection {

    /// Converts a `CLLocationDirection` to an `NSNumber` containing a `Double`.
    var NSNumber: NSNumber {
        Foundation.NSNumber(value: Double(self))
    }
}
