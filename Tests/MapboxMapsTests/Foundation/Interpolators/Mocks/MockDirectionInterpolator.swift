@testable import MapboxMaps
import CoreLocation

final class MockDirectionInterpolator: DirectionInterpolatorProtocol {

    struct InterpolateParams {
        var from: CLLocationDirection
        var to: CLLocationDirection
        var fraction: Double
    }
    let interpolateStub = Stub<InterpolateParams, CLLocationDirection>(defaultReturnValue: 340)
    func interpolate(from: CLLocationDirection,
                     to: CLLocationDirection,
                     fraction: Double) -> CLLocationDirection {
        interpolateStub.call(with: .init(
            from: from,
            to: to,
            fraction: fraction))
    }
}
