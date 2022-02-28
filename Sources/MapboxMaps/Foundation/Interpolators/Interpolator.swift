internal protocol InterpolatorProtocol {
    func interpolate(from: Double, to: Double, fraction: Double) -> Double
}

internal final class Interpolator: InterpolatorProtocol {
    internal func interpolate(from: Double,
                              to: Double,
                              fraction: Double) -> Double {
        return from + (to - from) * fraction
    }
}
