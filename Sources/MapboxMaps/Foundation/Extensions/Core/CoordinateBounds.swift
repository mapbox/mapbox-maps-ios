import Foundation
import MapboxCoreMaps

// MARK: - CoordinateBounds

public extension CoordinateBounds {

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

    /// Returns a new `CoordinateBounds` that stretches to contain both this and another `CoordinateBounds`.
    /// - Parameter coordinateBounds: The `CoordinateBounds` to add.
    /// - Returns: A bounds whose area encompasses the two bounds and the space between them.
    func union(_ coordinateBounds: CoordinateBounds) -> CoordinateBounds {
        extend(forArea: coordinateBounds)
    }

    /// Extends these bounds to include `point`.
    /// - Parameter coordinate: The coordinate to be included.
    /// - Returns: The extended bounds.
    func include(_ coordinate: CLLocationCoordinate2D) -> CoordinateBounds {
        extend(forPoint: coordinate)
    }

    /// Returns a new `CoordinateBounds` that is the intersection of this with another `CoordinateBounds`.
    /// - Parameter coordinateBounds: The `CoordinateBounds` to intersect with.
    /// - Returns: The bounds representing the intersection of the two bounds or null if there is no intersection.
    func intersect(_ coordinateBounds: CoordinateBounds) -> CoordinateBounds? {
        let minWest = max(coordinateBounds.west, west)
        let maxEast = min(coordinateBounds.east, east)

        guard maxEast >= minWest else { return nil }

        let minSouth = max(coordinateBounds.south, south)
        let maxNorth = min(coordinateBounds.north, north)

        guard maxNorth >= minSouth else { return nil }

        return CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: minSouth, longitude: minWest),
                                northeast: CLLocationCoordinate2D(latitude: maxNorth, longitude: maxEast))
    }

    // MARK: - Equality

    override var hash: Int {
        return Int((north + 90)
        + (south + 90) * 1000
        + (east + 180) * 1000000
        + (west + 180) * 1000000000)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CoordinateBounds else {
            return false
        }

        return self == other
    }

    static func == (lhs: CoordinateBounds, rhs: CoordinateBounds) -> Bool {
        return lhs.north == rhs.north &&
        lhs.south == rhs.south &&
        lhs.west == rhs.west &&
        lhs.east == rhs.east
    }
}
