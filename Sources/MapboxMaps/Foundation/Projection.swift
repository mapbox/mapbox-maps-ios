import CoreLocation

/// A collection of [Spherical Mercator](https://en.wikipedia.org/wiki/Web_Mercator_projection) projection methods.
public final class Projection {
    /// Maximum supported latitude value.
    public static let latitudeMax: CLLocationDegrees = +85.051128779806604
    /// Minimum supported latitude value.
    public static let latitudeMin: CLLocationDegrees = -85.051128779806604
    /// Valid mercator latitude range.
    public static let latitudeRange = (latitudeMin...latitudeMax)

    internal init() {}

    /// Calculate distance spanned by one pixel at the specified latitude and
    /// zoom level.
    ///
    /// - Parameters:
    ///   - latitude: The latitude for which to return the value
    ///   - zoom: The zoom level
    ///
    /// - Returns: Meters
    public static func metersPerPoint(for latitude: CLLocationDegrees, zoom: CGFloat) -> Double {
        return CoreProjection.getMetersPerPixelAtLatitude(forLatitude: latitude, zoom: Double(zoom))
    }

    /// Calculate Spherical Mercator ProjectedMeters coordinates.
    /// - Parameter coordinate: Coordinate at which to calculate the projected
    ///     meters
    ///
    /// - Returns: Spherical Mercator ProjectedMeters coordinates
    public static func projectedMeters(for coordinate: CLLocationCoordinate2D) -> ProjectedMeters {
        return CoreProjection.projectedMetersForCoordinate(for: coordinate)
    }

    /// Calculate a coordinate for a Spherical Mercator projected
    /// meters.
    ///
    /// - Parameter projectedMeters: Spherical Mercator ProjectedMeters coordinates
    ///
    /// - Returns: A coordinate
    public static func coordinate(for projectedMeters: ProjectedMeters) -> CLLocationCoordinate2D {
        return CoreProjection.coordinateForProjectedMeters(for: projectedMeters)
    }

    /// Calculate a point on the map in Mercator Projection for a given
    /// coordinate at the specified zoom scale.
    ///
    /// - Parameters:
    ///   - coordinate: The coordinate for which to return the value.
    ///   - zoomScale: The current zoom factor applied on the map, is used to
    ///         calculate the world size as tileSize * zoomScale (i.e.
    ///         512 * 2 ^ Zoom level) where tileSize is the width of a tile
    ///         in points.
    /// - Returns: Mercator coordinate
    ///
    /// - Note: Coordinate latitudes will be clamped to
    ///     [Projection.latitudeMin, Projection.latitudeMax]
    public static func project(_ coordinate: CLLocationCoordinate2D, zoomScale: CGFloat) -> MercatorCoordinate {
        return CoreProjection.project(for: coordinate, zoomScale: Double(zoomScale))
    }

    /// Calculate a coordinate for a given point on the map in Mercator Projection.
    ///
    /// - Parameters:
    ///   - mercatorCoordinate: Point on the map in Mercator projection.
    ///   - zoomScale: The current zoom factor applied on the map, is used to
    ///         calculate the world size as tileSize * zoomScale (i.e.
    ///         512 * 2 ^ Zoom level) where tileSize is the width of a tile in
    ///         points.
    /// - Returns: Unprojected coordinate
    public static func unproject(_ mercatorCoordinate: MercatorCoordinate, zoomScale: CGFloat) -> CLLocationCoordinate2D {
        return CoreProjection.unproject(for: mercatorCoordinate, zoomScale: Double(zoomScale))
    }

    /// Calculates the scale factor for a given latitude.
    ///
    /// - Parameter latitude: The latitude in degrees for which to compute the scale.
    /// - Returns: The scale factor (as a 64-bit floating point number) at the specified latitude.
    public static func getLatitudeScale(_ latitude: CLLocationDegrees) -> Double {
        return CoreProjection.getLatitudeScale(forLatitude: latitude)
    }

    /// Converts a geographic coordinate to its corresponding
    /// Mercator projection coordinates (X, Y).
    ///
    /// - Parameter coordinate: The geographic coordinate to convert.
    /// - Returns: A `Vec2` representing the X and Y coordinates in the Mercator projection.
    public static func latLngToMercatorXY(coordinate: CLLocationCoordinate2D) -> MercatorCoordinate {
        let vec = CoreProjection.latLngToMercatorXY(for: coordinate)
        return MercatorCoordinate(x: vec.x, y: vec.y)
    }

    /// Calculates the map pixel width at a given scale.
    ///
    /// - Parameter scale: The current zoom applied on the map.
    /// - Returns: The map pixel width.
    public static func worldSize(scale: Double) -> Double {
        return CoreProjection.worldSize(forScale: scale)
    }
}

internal extension Projection {
    /// Calculate the shift between two points in Mercator coordinate.
    ///
    /// - Parameters:
    ///   - startPoint: The start point for the calculation.
    ///   - endPoint: The start point for the calculation.
    ///   - zoomLevel:The zoom level that applies to the calculation.
    ///
    /// - Returns: The mercator coordinate representing the shift between startPoint and endPoint.
    static func calculateMercatorCoordinateShift(startPoint: Point, endPoint: Point, zoomLevel: Double) -> MercatorCoordinate {
        let centerMercatorCoordinate = Projection.project(startPoint.coordinates, zoomScale: zoomLevel)
        let targetMercatorCoordinate = Projection.project(endPoint.coordinates, zoomScale: zoomLevel)
        return MercatorCoordinate(
            x: targetMercatorCoordinate.x - centerMercatorCoordinate.x,
            y: targetMercatorCoordinate.y - centerMercatorCoordinate.y
        )
    }

    /// Apply a MercatorCoordinate to the original point.
    ///
    /// - Parameters:
    ///   - point: The point to be shifted..
    ///   - shiftMercatorCoordinate: The shift that applied to the original point.
    ///   - zoomLevel:The zoom level that applies to the calculation.
    ///
    /// - Returns: A shifted point with the applied shiftMercatorCoordinate.
    static func shiftPointWithMercatorCoordinate(point: Point, shiftMercatorCoordinate: MercatorCoordinate, zoomLevel: Double) -> Point {
        let mercatorCoordinate = Projection.project(point.coordinates, zoomScale: zoomLevel)
        let shiftedMercatorCoordinate = MercatorCoordinate(
            x: mercatorCoordinate.x + shiftMercatorCoordinate.x,
            y: mercatorCoordinate.y + shiftMercatorCoordinate.y
        )
        return Point(Projection.unproject(shiftedMercatorCoordinate, zoomScale: zoomLevel))
    }
}
