@testable import MapboxMaps
import XCTest
import CoreLocation

final class MockCoordinateInterpolator: CoordinateInterpolatorProtocol {
    struct InterpolateParams {
        var from: CLLocationCoordinate2D
        var to: CLLocationCoordinate2D
        var fraction: Double
    }
    let interpolateStub = Stub<InterpolateParams, CLLocationCoordinate2D>(defaultReturnValue: .random())
    func interpolate(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, fraction: Double) -> CLLocationCoordinate2D {
        interpolateStub.call(with: .init(from: from, to: to, fraction: fraction))
    }
}
