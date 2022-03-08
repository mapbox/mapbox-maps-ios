@testable import MapboxMaps
import CoreLocation

final class MockLongitudeInterpolator: LongitudeInterpolatorProtocol {
    struct InterpolateParams {
        var from: CLLocationDegrees
        var to: CLLocationDegrees
        var fraction: Double
    }
    let interpolateStub = Stub<InterpolateParams, CLLocationDegrees>(defaultReturnValue: .random(in: -180..<180))
    func interpolate(from: CLLocationDegrees,
                     to: CLLocationDegrees,
                     fraction: Double) -> CLLocationDegrees {
        interpolateStub.call(with: .init(
            from: from,
            to: to,
            fraction: fraction))
    }
}
