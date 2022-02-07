internal protocol LocationInterpolatorProtocol: AnyObject {
    func interpolate(from fromLocation: InterpolatedLocation,
                     to toLocation: InterpolatedLocation,
                     percent: Double) -> InterpolatedLocation
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
                              percent: Double) -> InterpolatedLocation {
        let course: CLLocationDirection?
        if let startCourse = fromLocation.course,
           let endCourse = toLocation.course {
            course = directionInterpolator.interpolate(
                from: startCourse,
                to: endCourse,
                percent: percent)
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
                percent: percent)
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
                    percent: percent),
                longitude: interpolator.interpolate(
                    from: fromLocation.coordinate.longitude,
                    to: toLocation.coordinate.longitude,
                    percent: percent)),
            altitude: interpolator.interpolate(
                from: fromLocation.altitude,
                to: toLocation.altitude,
                percent: percent),
            horizontalAccuracy: interpolator.interpolate(
                from: fromLocation.horizontalAccuracy,
                to: toLocation.horizontalAccuracy,
                percent: percent),
            course: course,
            heading: heading,
            accuracyAuthorization: toLocation.accuracyAuthorization)
    }
}
