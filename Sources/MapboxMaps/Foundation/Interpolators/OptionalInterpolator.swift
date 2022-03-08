internal struct OptionalInterpolator {
    internal func interpolate<T>(from: T?,
                                 to: T?,
                                 fraction: Double,
                                 interpolate: (T, T, Double) -> T) -> T? {
        if let from = from, let to = to {
            return interpolate(from, to, fraction)
        } else {
            return nil
        }
    }
}
