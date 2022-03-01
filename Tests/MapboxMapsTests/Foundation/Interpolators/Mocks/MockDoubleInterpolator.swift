@testable import MapboxMaps

final class MockDoubleInterpolator: DoubleInterpolatorProtocol {
    struct InterpolateParams: Equatable {
        var from: Double
        var to: Double
        var fraction: Double
    }
    let interpolateStub = Stub<InterpolateParams, Double>(defaultReturnValue: 0)
    func interpolate(from: Double, to: Double, fraction: Double) -> Double {
        interpolateStub.call(with: .init(from: from, to: to, fraction: fraction))
    }
}
