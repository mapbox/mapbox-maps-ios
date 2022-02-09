@testable import MapboxMaps

final class MockLocationInterpolator: LocationInterpolatorProtocol {
    struct InterpolateParams {
        var fromLocation: InterpolatedLocation
        var toLocation: InterpolatedLocation
        var fraction: Double
    }
    let interpolateStub = Stub<InterpolateParams, InterpolatedLocation>(defaultReturnValue: .random())
    func interpolate(from fromLocation: InterpolatedLocation,
                     to toLocation: InterpolatedLocation,
                     fraction: Double) -> InterpolatedLocation {
        interpolateStub.call(with: .init(
            fromLocation: fromLocation,
            toLocation: toLocation,
            fraction: fraction))
    }
}
