import CoreLocation

public struct InterpolatedLocation: Equatable {
    public internal(set) var coordinate: CLLocationCoordinate2D
    public internal(set) var altitude: CLLocationDistance
    public internal(set) var horizontalAccuracy: CLLocationAccuracy
    public internal(set) var course: CLLocationDirection?
    public internal(set) var heading: CLLocationDirection?
    public internal(set) var accuracyAuthorization: CLAccuracyAuthorization

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
}
