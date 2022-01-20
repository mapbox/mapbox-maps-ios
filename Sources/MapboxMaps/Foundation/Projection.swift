import CoreLocation

public final class Projection {
    public static let latitudeMax: CLLocationDegrees = +85.051128779806604
    public static let latitudeMin: CLLocationDegrees = -85.051128779806604

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
        return MapboxCoreMaps.Projection.getMetersPerPixelAtLatitude(forLatitude: latitude, zoom: Double(zoom))
    }

    /// Calculate Spherical Mercator ProjectedMeters coordinates.
    /// - Parameter coordinate: Coordinate at which to calculate the projected
    ///     meters
    ///
    /// - Returns: Spherical Mercator ProjectedMeters coordinates
    public static func projectedMeters(for coordinate: CLLocationCoordinate2D) -> ProjectedMeters {
        return MapboxCoreMaps.Projection.projectedMetersForCoordinate(for: coordinate)
    }

    /// Calculate a coordinate for a Spherical Mercator projected
    /// meters.
    ///
    /// - Parameter projectedMeters: Spherical Mercator ProjectedMeters coordinates
    ///
    /// - Returns: A coordinate
    public static func coordinate(for projectedMeters: ProjectedMeters) -> CLLocationCoordinate2D {
        return MapboxCoreMaps.Projection.coordinateForProjectedMeters(for: projectedMeters)
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
        return MapboxCoreMaps.Projection.project(for: coordinate, zoomScale: Double(zoomScale))
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
        return MapboxCoreMaps.Projection.unproject(for: mercatorCoordinate, zoomScale: Double(zoomScale))
    }
}
