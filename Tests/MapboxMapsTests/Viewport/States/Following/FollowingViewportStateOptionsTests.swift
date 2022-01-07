import XCTest
import MapboxMaps

final class FollowingViewportStateOptionsTests: XCTestCase {
    func testInitializerDefaultParameters() {
        let options = FollowingViewportStateOptions()

        XCTAssertEqual(options.zoom, 15)
        XCTAssertEqual(options.pitch, 40)
        XCTAssertEqual(options.bearing, .constant(0))
    }

    func testInitializer() {
        let zoom = CGFloat.random(in: 0...20)
        let pitch = CGFloat.random(in: 0...80)
        let bearing = FollowingViewportStateBearing.random()

        let options = FollowingViewportStateOptions(
            zoom: zoom,
            pitch: pitch,
            bearing: bearing)

        XCTAssertEqual(options.zoom, zoom)
        XCTAssertEqual(options.pitch, pitch)
        XCTAssertEqual(options.bearing, bearing)
    }
}
