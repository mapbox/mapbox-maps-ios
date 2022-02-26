internal protocol InterpolatorProtocol {
    func interpolate(from: Double, to: Double, fraction: Double) -> Double
}

internal final class Interpolator: InterpolatorProtocol {
    internal func interpolate(from: Double, to: Double, fraction: Double) -> Double {
        return from + (to - from) * fraction
    }
}

internal final class WrappingInterpolator: InterpolatorProtocol {
    private let range: Range<Double>

    internal init(range: Range<Double>) {
        self.range = range
    }

    internal func interpolate(from: Double, to: Double, fraction: Double) -> Double {
        let wrappedFrom = from.wrapped(to: range)
        let wrappedTo = to.wrapped(to: range)
        let resolvedTo: Double
        let rangeWidth = (range.upperBound - range.lowerBound)
        let halfRangeWidth = rangeWidth / 2
        if wrappedFrom < wrappedTo {
            if wrappedTo - wrappedFrom < halfRangeWidth {
                resolvedTo = wrappedTo
            } else {
                resolvedTo = wrappedTo - rangeWidth
            }
        } else {
            if wrappedFrom - wrappedTo < halfRangeWidth {
                resolvedTo = wrappedTo
            } else {
                resolvedTo = wrappedTo + rangeWidth
            }
        }
        return (wrappedFrom + (resolvedTo - wrappedFrom) * fraction).wrapped(to: range)
    }
}
