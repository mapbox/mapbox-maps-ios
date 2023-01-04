import CoreLocation

internal protocol HeadingInterpolatorProtocol: AnyObject {
    func interpolate(from: InterpolatedHeading,
                     to: InterpolatedHeading,
                     fraction: Double) -> InterpolatedHeading
}

internal final class HeadingInterpolator: HeadingInterpolatorProtocol {
    private let directionInterpolator: DirectionInterpolatorProtocol

    internal init(directionInterpolator: DirectionInterpolatorProtocol) {
        self.directionInterpolator = directionInterpolator
    }

    internal func interpolate(from: InterpolatedHeading,
                              to: InterpolatedHeading,
                              fraction: Double) -> InterpolatedHeading {
        let magneticHeading = directionInterpolator.interpolate(
            from: from.magneticHeading,
            to: to.magneticHeading,
            fraction: fraction
        )
        let trueHeading = directionInterpolator.interpolate(
            from: from.trueHeading,
            to: to.trueHeading,
            fraction: fraction
        )
        let headingAccuracy = directionInterpolator.interpolate(
            from: from.headingAccuracy,
            to: to.headingAccuracy,
            fraction: fraction
        )

        return InterpolatedHeading(
            magneticHeading: magneticHeading,
            trueHeading: trueHeading,
            headingAccuracy: headingAccuracy
        )
    }
}
