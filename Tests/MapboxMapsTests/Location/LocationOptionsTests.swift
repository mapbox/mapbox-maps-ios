import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsLocation
import MapboxMapsFoundation
#endif

final class LocationOptionsTests: XCTestCase {
    func testLocationOptionsPuckTypeDefaultIsNil() {
        let locationOptions = LocationOptions()
        XCTAssertNil(locationOptions.puckType)
    }
}
