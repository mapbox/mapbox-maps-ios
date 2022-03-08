import XCTest
import MapboxMaps

final class LocationOptionsTests: XCTestCase {
    func testLocationOptionsPuckTypeDefault() {
        let locationOptions = LocationOptions()
        XCTAssertNil(locationOptions.puckType)
    }

    func testLocationOptionsDistanceFailterDefault() {
        let locationOptions = LocationOptions()
        XCTAssertEqual(locationOptions.distanceFilter, kCLDistanceFilterNone)
    }

    func testLocationOptionsDesiredAccuracyDefault() {
        let locationOptions = LocationOptions()
        XCTAssertEqual(locationOptions.desiredAccuracy, kCLLocationAccuracyBest)
    }

    func testLocationOptionsActivityTypeDefault() {
        let locationOptions = LocationOptions()
        XCTAssertEqual(locationOptions.activityType, .other)
    }

    func testLocationOptionsPuckBearingSourceDefault() {
        let locationOptions = LocationOptions()
        XCTAssertEqual(locationOptions.puckBearingSource, .heading)
    }

    func testLocationOptionsPuckBearingEnableDefault() {
        let locationOptions = LocationOptions()
        XCTAssertEqual(locationOptions.puckBearingEnabled, true)
    }
}
