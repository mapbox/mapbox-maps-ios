import Foundation
import MapboxCoreMaps

// MARK: - CoordinateBounds

public extension CoordinateBounds {

    /// Returns a bounds covering the entire (unwrapped) world.
    static var world: CoordinateBounds { __world() }

    /// Returns the southern latitude of the bounds.
    var south: CLLocationDegrees { __south() }

    /// Returns the western longitude of the bounds.
    var west: CLLocationDegrees { __west() }

    /// Returns the northern latitude of the bounds.
    var north: CLLocationDegrees { __north() }

    /// Returns the eastern longitude of the bounds.
    var east: CLLocationDegrees { __east() }

    /// The centerpoint of this `CoordinateBounds` calculated by simple interpolation.
    /// This is a non-geodesic calculation which is not the geographic center.
    var center: CLLocationCoordinate2D { __center() }

    /// Returns whether the bounds are empty or not.
    var isEmpty: Bool { __isEmpty() }

    /// The absolute distance, in degrees, between the north and south boundaries of these bounds.
    ///
    /// One degree of latitude is approximately 111 kilometers (69 miles).
    var latitudeSpan: CLLocationDegrees { __latitudeSpan() }

    /// The absolute distance, in degrees, between the west and east boundaries of these bounds.
    ///
    /// The distance represented by a longitude span varies on current latitude.
    /// At the equator one degree of longitude represents a distance of approximately 111 kilometers (69 miles).
    /// While at the poles one degree of logitude span is 0 kilometers (0 miles).
    var longitudeSpan: CLLocationDegrees { __longitudeSpan() }

    /// The northwest coordinate of the bounds.
    var northwest: CLLocationCoordinate2D { __northwest() }

    /// The southeast coordinate of the bounds.
    var southeast: CLLocationCoordinate2D { __southeast() }
}
