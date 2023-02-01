import CoreLocation

internal protocol LongitudeInterpolatorProtocol: AnyObject {
    func interpolate(from: CLLocationDegrees,
                     to: CLLocationDegrees,
                     fraction: Double) -> CLLocationDegrees
}

internal final class LongitudeInterpolator: LongitudeInterpolatorProtocol {
    private let wrappingInterpolator: WrappingInterpolatorProtocol

    internal init(wrappingInterpolator: WrappingInterpolatorProtocol) {
        self.wrappingInterpolator = wrappingInterpolator
    }

    internal func interpolate(from: CLLocationDegrees,
                              to: CLLocationDegrees,
                              fraction: Double) -> CLLocationDegrees {
        wrappingInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction,
            range: -180..<180)
    }
}
