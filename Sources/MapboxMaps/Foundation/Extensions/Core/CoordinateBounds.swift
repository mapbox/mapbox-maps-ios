import Foundation
import MapboxCoreMaps

// MARK: - CoordinateBounds

public extension CoordinateBounds {

    /// The centerpoint of this `CoordinateBounds` calculated by simple interpolation.
    /// This is a non-geodesic calculation which is not the geographic center.
    var center: CLLocationCoordinate2D {
        return __center()
    }

    /// The absolute distance, in degrees, between the north and south boundaries of these bounds.
    ///
    /// One degree of latitude is approximately 111 kilometers (69 miles).
    var latitudeSpan: CLLocationDegrees {
        __latitudeSpan()
    }

    /// The absolute distance, in degrees, between the west and east boundaries of these bounds.
    ///
    /// The distance represented by a longitude span varies on current latitude.
    /// At the equator one degree of longitude represents a distance of approximately 111 kilometers (69 miles).
    /// While at the poles one degree of logitude span is 0 kilometers (0 miles).
    var longitudeSpan: CLLocationDegrees {
        __longitudeSpan()
    }


    /// The northwest coordinate of an internal `CoordinateBounds` type.
    var northwest: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: __north(), longitude: __west())
    }

    /// The northwest coordinate of an internal `CoordinateBounds` type.
    var southeast: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: __south(), longitude: __east())
    }

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
        let minWest = max(coordinateBounds.__west(), __west())
        let maxEast = min(coordinateBounds.__east(), __east())

        guard maxEast >= minWest else { return nil }

        let minSouth = max(coordinateBounds.__south(), __south())
        let maxNorth = min(coordinateBounds.__north(), __north())

        guard maxNorth >= minSouth else { return nil }

        return CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: minSouth, longitude: minWest),
                                northeast: CLLocationCoordinate2D(latitude: maxNorth, longitude: maxEast))
    }
}

internal extension CoordinateBounds {
    func contains(_ coordinates: [CLLocationCoordinate2D]) -> Bool {
        return coordinates.first { contains(forPoint: $0, wrappedCoordinates: false) } != nil
    }
}
