@testable import MapboxMaps

final class MockLocationInterpolator: LocationInterpolatorProtocol {
    struct InterpolateParams {
        var fromLocation: InterpolatedLocation
        var toLocation: InterpolatedLocation
        var percent: Double
    }
    let interpolateStub = Stub<InterpolateParams, InterpolatedLocation>(defaultReturnValue: .random())
    func interpolate(from fromLocation: InterpolatedLocation,
                     to toLocation: InterpolatedLocation,
                     percent: Double) -> InterpolatedLocation {
        interpolateStub.call(with: .init(
            fromLocation: fromLocation,
            toLocation: toLocation,
            percent: percent))
    }
}
