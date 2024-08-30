import XCTest
@testable import MapboxMaps

final class LocationTests: XCTestCase {
    func testAuthorizationAccuracy() {
        let coordinate = CLLocationCoordinate2D.testConstantValue()
        let date = Date()
        let loc1 = Location(coordinate: coordinate, timestamp: date, extra: Location.makeExtra(for: .fullAccuracy))
        let loc2 = Location(coordinate: coordinate, timestamp: date, extra: Location.makeExtra(for: .fullAccuracy))

        XCTAssertEqual(loc1.accuracyAuthorization, .fullAccuracy)
        XCTAssertEqual(loc1, loc2)

        let loc3 = Location(coordinate: .testConstantValue(), extra: Location.makeExtra(for: .reducedAccuracy))
        XCTAssertEqual(loc3.accuracyAuthorization, .reducedAccuracy)
    }
}
