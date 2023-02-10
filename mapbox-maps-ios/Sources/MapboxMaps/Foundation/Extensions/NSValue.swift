import CoreLocation

extension NSValue {

    /// Converts the `CGPoint` value of an `NSValue` to a `CLLocationCoordinate2D`.
    func coordinateValue() -> CLLocationCoordinate2D {
        let point = cgPointValue
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(point.x), longitude: CLLocationDegrees(point.y))
    }

    /// Converts an array of `CGPoint` values wrapped in an `NSValue`
    /// to an array of `CLLocationCoordinate2D`.
    internal static func toCoordinates(array: [NSValue]) -> [CLLocationCoordinate2D] {
        return array.map({ $0.coordinateValue() })
    }

    /// Converts a two-dimensional array of `CGPoint` values wrapped in an `NSValue`
    /// to a two-dimensional array of `CLLocationCoordinate2D`.
    internal static func toCoordinates2D(array: [[NSValue]]) -> [[CLLocationCoordinate2D]] {
        return array.map({ toCoordinates(array: $0) })
    }

    /// Converts a three-dimensional array of `CGPoint` values wrapped in an `NSValue`
    /// to a three-dimensional array of `CLLocationCoordinate2D`.
    internal static func toCoordinates3D(array: [[[NSValue]]]) -> [[[CLLocationCoordinate2D]]] {
        return array.map({ toCoordinates2D(array: $0) })
    }
}
