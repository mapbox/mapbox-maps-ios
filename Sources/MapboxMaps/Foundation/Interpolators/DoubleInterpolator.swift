internal protocol DoubleInterpolatorProtocol {
    func interpolate(from: Double, to: Double, fraction: Double) -> Double
}

internal final class DoubleInterpolator: DoubleInterpolatorProtocol {
    internal func interpolate(from: Double,
                              to: Double,
                              fraction: Double) -> Double {
        return from + (to - from) * fraction
    }
}
