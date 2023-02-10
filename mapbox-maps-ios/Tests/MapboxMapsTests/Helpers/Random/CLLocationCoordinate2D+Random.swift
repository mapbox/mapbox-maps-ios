import CoreLocation

extension CLLocationCoordinate2D {
    static func random() -> Self {
        return CLLocationCoordinate2D(
            latitude: .random(in: -90...90),
            longitude: .random(in: -180..<180))
    }
}
