import CoreLocation.CLLocation

/// `CLLocationCoordinate2D` with Codable & Hashable support
internal struct CLLocationCoordinate2DCodable: Codable, Hashable {
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
}

extension CLLocationCoordinate2DCodable {
    var coordinates: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }

    init(_ coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
}
