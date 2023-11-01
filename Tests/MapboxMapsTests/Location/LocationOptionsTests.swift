import XCTest
import MapboxMaps

final class LocationOptionsTests: XCTestCase {
    func testLocationOptionsPuckTypeDefault() {
        let locationOptions = LocationOptions()
        XCTAssertNil(locationOptions.puckType)
    }

    func testLocationOptionsPuckBearingDefault() {
        let locationOptions = LocationOptions()
        XCTAssertEqual(locationOptions.puckBearing, .heading)
    }

    func testLocationOptionsPuckBearingEnableDefault() {
        let locationOptions = LocationOptions()
        XCTAssertEqual(locationOptions.puckBearingEnabled, false)
    }
}
