import Foundation
import CoreLocation
import CoreGraphics
import MapboxCoreMaps

// MARK: - CLLocationCoordinate2D
extension CLLocationCoordinate2D {

    /// Converts a `CLLocationCoordinate` to a `CLLocation`.
    internal var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    /// Returns a new `CLLocationCoordinate` value with a new longitude constrained to [-180, +180] degrees.
    internal func wrap() -> CLLocationCoordinate2D {
        /**
         mbgl::geo.hpp equivalent:

         void wrap() {
             lon = util::wrap(lon, -util::LONGITUDE_MAX, util::LONGITUDE_MAX);
         }
         */

        let wrappedLongitude = Utils.wrap(forValue: longitude, min: -180.0, max: 180.0)

        return CLLocationCoordinate2D(latitude: latitude, longitude: wrappedLongitude)
    }

    /// Returns a new `CLLocationCoordinate` where the longitude is wrapped if
    /// the distance from start to end longitudes is between a half and full
    /// world, ensuring that the shortest path is taken.
    /// - Parameter end: The coordinate to possibly wrap, if needed.
    internal func unwrapForShortestPath(_ end: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
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
        return NSValue(cgPoint: CGPoint(x: latitude, y: longitude))
    }
}

// MARK: - CLLocationDirection
extension CLLocationDirection {

    /// Converts a `CLLocationDirection` to an `NSNumber` containing a `Double`.
    internal var NSNumber: NSNumber {
        Foundation.NSNumber(value: Double(self))
    }
}
