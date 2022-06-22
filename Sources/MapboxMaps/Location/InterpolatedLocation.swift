import CoreLocation

internal struct InterpolatedLocation: Equatable {
    internal var coordinate: CLLocationCoordinate2D
    internal var altitude: CLLocationDistance
    internal var horizontalAccuracy: CLLocationAccuracy
    internal var course: CLLocationDirection?
    internal var heading: CLLocationDirection?
    internal var accuracyAuthorization: CLAccuracyAuthorization

    internal init(coordinate: CLLocationCoordinate2D,
                  altitude: CLLocationDistance,
                  horizontalAccuracy: CLLocationAccuracy,
                  course: CLLocationDirection?,
                  heading: CLLocationDirection?,
                  accuracyAuthorization: CLAccuracyAuthorization) {
        self.coordinate = coordinate
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.course = course
        self.heading = heading
        self.accuracyAuthorization = accuracyAuthorization
    }

    internal init(location: Location) {
        self.coordinate = location.location.coordinate
        self.altitude = location.location.altitude
        self.horizontalAccuracy = location.location.horizontalAccuracy
        self.course = location.location.course >= 0 ? location.location.course : nil
        self.heading = location.headingDirection
        self.accuracyAuthorization = location.accuracyAuthorization
    }

    internal var location: Location {
        Location(
            location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude),
            heading: nil,
            accuracyAuthorization: accuracyAuthorization
        )
    }
}
