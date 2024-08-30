import CoreLocation

extension CLLocationCoordinate2D {
    static func testConstantValue() -> Self {
        return CLLocationCoordinate2D(
            latitude: .testConstantValue(),
            longitude: .testConstantValue())
    }
}
