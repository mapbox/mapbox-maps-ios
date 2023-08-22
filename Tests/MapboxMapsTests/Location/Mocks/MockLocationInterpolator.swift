@testable import MapboxMaps

final class MockLocationInterpolator: LocationInterpolatorProtocol {
    struct InterpolateParams {
        var fromLocation: [Location]
        var toLocation: [Location]
        var fraction: Double
    }
    let interpolateStub = Stub<InterpolateParams, [Location]>(defaultReturnValue: [.random()])
    func interpolate(from fromLocation: [Location],
                     to toLocation: [Location],
                     fraction: Double) -> [Location] {
        interpolateStub.call(with: .init(
            fromLocation: fromLocation,
            toLocation: toLocation,
            fraction: fraction))
    }
}
