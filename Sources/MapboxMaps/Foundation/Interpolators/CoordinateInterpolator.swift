import CoreLocation

internal protocol CoordinateInterpolatorProtocol: AnyObject {
    func interpolate(from: CLLocationCoordinate2D,
                     to: CLLocationCoordinate2D,
                     fraction: Double) -> CLLocationCoordinate2D
}

internal final class CoordinateInterpolator: CoordinateInterpolatorProtocol {
    private let interpolator: InterpolatorProtocol
    private let longitudeInterpolator: InterpolatorProtocol

    internal init(interpolator: InterpolatorProtocol,
                  longitudeInterpolator: InterpolatorProtocol) {
        self.interpolator = interpolator
        self.longitudeInterpolator = longitudeInterpolator
    }

    func interpolate(from: CLLocationCoordinate2D,
                     to: CLLocationCoordinate2D,
                     fraction: Double) -> CLLocationCoordinate2D {
        let latitude = interpolator.interpolate(
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
