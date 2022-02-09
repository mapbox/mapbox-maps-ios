internal protocol LocationInterpolatorProtocol: AnyObject {
    func interpolate(from fromLocation: InterpolatedLocation,
                     to toLocation: InterpolatedLocation,
                     fraction: Double) -> InterpolatedLocation
}

internal final class LocationInterpolator: LocationInterpolatorProtocol {

    private let interpolator: InterpolatorProtocol
    private let directionInterpolator: InterpolatorProtocol
    private let latitudeInterpolator: InterpolatorProtocol

    internal init(interpolator: InterpolatorProtocol,
                  directionInterpolator: InterpolatorProtocol,
                  latitudeInterpolator: InterpolatorProtocol) {
        self.interpolator = interpolator
        self.directionInterpolator = directionInterpolator
        self.latitudeInterpolator = latitudeInterpolator
    }

    internal func interpolate(from fromLocation: InterpolatedLocation,
                              to toLocation: InterpolatedLocation,
                              fraction: Double) -> InterpolatedLocation {
        let course: CLLocationDirection?
        if let startCourse = fromLocation.course,
           let endCourse = toLocation.course {
            course = directionInterpolator.interpolate(
                from: startCourse,
                to: endCourse,
                fraction: fraction)
        } else if let endCourse = toLocation.course {
            course = endCourse
        } else {
            course = nil
        }

        let heading: CLLocationDirection?
        if let startHeading = fromLocation.heading,
           let endHeading = toLocation.heading {
            heading = directionInterpolator.interpolate(
                from: startHeading,
                to: endHeading,
                fraction: fraction)
        } else if let endHeading = toLocation.heading {
            heading = endHeading
        } else {
            heading = nil
        }

        return InterpolatedLocation(
            coordinate: CLLocationCoordinate2D(
                latitude: latitudeInterpolator.interpolate(
                    from: fromLocation.coordinate.latitude,
                    to: toLocation.coordinate.latitude,
                    fraction: fraction),
                longitude: interpolator.interpolate(
                    from: fromLocation.coordinate.longitude,
                    to: toLocation.coordinate.longitude,
                    fraction: fraction)),
            altitude: interpolator.interpolate(
                from: fromLocation.altitude,
                to: toLocation.altitude,
                fraction: fraction),
            horizontalAccuracy: interpolator.interpolate(
                from: fromLocation.horizontalAccuracy,
                to: toLocation.horizontalAccuracy,
                fraction: fraction),
            course: course,
            heading: heading,
            accuracyAuthorization: toLocation.accuracyAuthorization)
    }
}
