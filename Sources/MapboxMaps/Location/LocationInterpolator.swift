internal protocol LocationInterpolatorProtocol: AnyObject {
    func interpolate(from fromLocation: InterpolatedLocation,
                     to toLocation: InterpolatedLocation,
                     fraction: Double) -> InterpolatedLocation
}

internal final class LocationInterpolator: LocationInterpolatorProtocol {
    private let doubleInterpolator: DoubleInterpolatorProtocol
    private let directionInterpolator: DirectionInterpolatorProtocol
    private let coordinateInterpolator: CoordinateInterpolatorProtocol
    private let optionalInterpolator = OptionalInterpolator()

    internal init(doubleInterpolator: DoubleInterpolatorProtocol,
                  directionInterpolator: DirectionInterpolatorProtocol,
                  coordinateInterpolator: CoordinateInterpolatorProtocol) {
        self.doubleInterpolator = doubleInterpolator
        self.directionInterpolator = directionInterpolator
        self.coordinateInterpolator = coordinateInterpolator
    }

    internal func interpolate(from fromLocation: InterpolatedLocation,
                              to toLocation: InterpolatedLocation,
                              fraction: Double) -> InterpolatedLocation {

        let coordinate = coordinateInterpolator.interpolate(
            from: fromLocation.coordinate,
            to: toLocation.coordinate,
            fraction: fraction)

        let altitude = doubleInterpolator.interpolate(
            from: fromLocation.altitude,
            to: toLocation.altitude,
            fraction: fraction)

        let horizontalAccuracy = doubleInterpolator.interpolate(
            from: fromLocation.horizontalAccuracy,
            to: toLocation.horizontalAccuracy,
            fraction: fraction)

        let course = optionalInterpolator.interpolate(
            from: fromLocation.course,
            to: toLocation.course,
            fraction: fraction,
            interpolate: directionInterpolator.interpolate(from:to:fraction:)) ?? toLocation.course

        let heading = optionalInterpolator.interpolate(
            from: fromLocation.heading,
            to: toLocation.heading,
            fraction: fraction,
            interpolate: directionInterpolator.interpolate(from:to:fraction:)) ?? toLocation.heading

        return InterpolatedLocation(
            coordinate: coordinate,
            altitude: altitude,
            horizontalAccuracy: horizontalAccuracy,
            course: course,
            heading: heading,
            accuracyAuthorization: toLocation.accuracyAuthorization)
    }
}
