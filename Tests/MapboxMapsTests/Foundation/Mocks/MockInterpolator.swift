@testable import MapboxMaps

final class MockInterpolator: InterpolatorProtocol {
    struct InterpolateParams: Equatable {
        var from: Double
        var to: Double
        var percent: Double
    }
    let interpolateStub = Stub<InterpolateParams, Double>(defaultReturnValue: 0)
    func interpolate(from: Double, to: Double, percent: Double) -> Double {
        interpolateStub.call(with: .init(from: from, to: to, percent: percent))
    }
}
