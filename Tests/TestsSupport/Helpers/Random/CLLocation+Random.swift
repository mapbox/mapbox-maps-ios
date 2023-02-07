import CoreLocation

extension CLLocation {
    static func random() -> CLLocation {
        return CLLocation(
            latitude: .random(in: -89...89),
            longitude: .random(in: -180..<180))
    }
}
