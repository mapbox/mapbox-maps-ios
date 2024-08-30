@testable import MapboxMaps

final class MockWrappingInterpolator: WrappingInterpolatorProtocol {
    struct InterpolateParams: Equatable {
        var from: Double
        var to: Double
        var fraction: Double
        var range: Range<Double>
    }
    let interpolateStub = Stub<InterpolateParams, Double>(defaultReturnValue: 0)
    func interpolate(from: Double,
                     to: Double,
                     fraction: Double,
                     range: Range<Double>) -> Double {
        interpolateStub.call(with: .init(
            from: from,
            to: to,
            fraction: fraction,
            range: range))
    }
}
