import CoreLocation

internal protocol CoordinateInterpolatorProtocol: AnyObject {
    func interpolate(from: CLLocationCoordinate2D,
                     to: CLLocationCoordinate2D,
                     fraction: Double) -> CLLocationCoordinate2D
}

internal final class CoordinateInterpolator: CoordinateInterpolatorProtocol {
    private let doubleInterpolator: DoubleInterpolatorProtocol
    private let longitudeInterpolator: LongitudeInterpolatorProtocol

    internal init(doubleInterpolator: DoubleInterpolatorProtocol,
                  longitudeInterpolator: LongitudeInterpolatorProtocol) {
        self.doubleInterpolator = doubleInterpolator
        self.longitudeInterpolator = longitudeInterpolator
    }

    func interpolate(from: CLLocationCoordinate2D,
                     to: CLLocationCoordinate2D,
                     fraction: Double) -> CLLocationCoordinate2D {
        let latitude = doubleInterpolator.interpolate(
            from: from.latitude,
            to: to.latitude,
            fraction: fraction)
        let longitude = longitudeInterpolator.interpolate(
            from: from.longitude,
            to: to.longitude,
            fraction: fraction)
        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude)
    }
}
