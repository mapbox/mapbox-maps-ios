import XCTest
@testable import MapboxMaps

final class LocationOptionsTests: XCTestCase {
    func testLocationOptionsPuckTypeDefaultIsNil() {
        let locationOptions = LocationOptions()
        XCTAssertNil(locationOptions.puckType)
    }
}
