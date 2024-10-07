import XCTest
import MapboxMaps

final class FollowPuckViewportStateOptionsTests: XCTestCase {
    func testInitializerDefaultParameters() {
        let options = FollowPuckViewportStateOptions()

        XCTAssertEqual(options.padding, nil)
        XCTAssertEqual(options.zoom, 16.35)
        XCTAssertEqual(options.bearing, .heading)
        XCTAssertEqual(options.pitch, 45)
    }

    func testInitializer() {
        let padding = UIEdgeInsets.testConstantValue()
        let zoom = 12.3
        let bearing = FollowPuckViewportStateBearing.testConstantValue()
        let pitch = 45.4

        let options = FollowPuckViewportStateOptions(
            padding: padding,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch)

        XCTAssertEqual(options.padding, padding)
        XCTAssertEqual(options.zoom, zoom)
        XCTAssertEqual(options.bearing, bearing)
        XCTAssertEqual(options.pitch, pitch)
    }

    func verifyEqual(_ lhs: FollowPuckViewportStateOptions, _ rhs: FollowPuckViewportStateOptions) {
        XCTAssertTrue(lhs == rhs)
        XCTAssertTrue(rhs == lhs)
        XCTAssertEqual(lhs.hashValue, rhs.hashValue)
    }

    func verifyNotEqual(_ lhs: FollowPuckViewportStateOptions, _ rhs: FollowPuckViewportStateOptions) {
        XCTAssertFalse(lhs == rhs)
        XCTAssertFalse(rhs == lhs)
    }

    func testEquatableAndHashable() {
        let options1 = FollowPuckViewportStateOptions(
            padding: .testConstantValue(),
            zoom: 12.5,
            bearing: .constant(0),
            pitch: 79.5)
        var options2 = options1
        verifyEqual(options1, options1)

        options2 = options1
        options2.padding?.top += 5
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.padding?.left += 3
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.padding?.bottom += 1
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.padding?.right += 8
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.zoom? += 9
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.bearing = .constant(7)
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.pitch? += 6
        verifyNotEqual(options1, options2)
    }

    func testEquatableAndHashableWithNils() {
        let options1 = FollowPuckViewportStateOptions(
            padding: nil,
            zoom: nil,
            bearing: nil,
            pitch: nil)
        var options2 = options1
        verifyEqual(options1, options1)

        options2 = options1
        options2.padding = .testConstantValue()
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.zoom = 4.6
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.bearing = .constant(65.4)
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.pitch = 65
        verifyNotEqual(options1, options2)
    }
}
