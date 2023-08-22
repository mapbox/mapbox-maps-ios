internal protocol WrappingInterpolatorProtocol: AnyObject {
    func interpolate(from: Double,
                     to: Double,
                     fraction: Double,
                     range: Range<Double>) -> Double
}

internal final class WrappingInterpolator: WrappingInterpolatorProtocol {
    internal func interpolate(from: Double,
                              to: Double,
                              fraction: Double,
                              range: Range<Double>) -> Double {
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
        return (wrappedFrom + (resolvedTo - wrappedFrom) * fraction)
            .wrapped(to: range)
    }
}
