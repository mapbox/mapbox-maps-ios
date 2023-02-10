import CoreLocation

internal protocol DirectionInterpolatorProtocol: AnyObject {
    func interpolate(from: CLLocationDirection,
                     to: CLLocationDirection,
                     fraction: Double) -> CLLocationDirection
}

internal final class DirectionInterpolator: DirectionInterpolatorProtocol {
    private let wrappingInterpolator: WrappingInterpolatorProtocol

    internal init(wrappingInterpolator: WrappingInterpolatorProtocol) {
        self.wrappingInterpolator = wrappingInterpolator
    }

    internal func interpolate(from: CLLocationDirection,
                              to: CLLocationDirection,
                              fraction: Double) -> CLLocationDirection {
        wrappingInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction,
            range: 0..<360)
    }
}
