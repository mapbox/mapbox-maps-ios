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
        let padding = UIEdgeInsets.random()
        let zoom = CGFloat.random(in: 0...20)
        let bearing = FollowPuckViewportStateBearing.random()
        let pitch = CGFloat.random(in: 0...80)

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
            padding: .random(),
            zoom: .random(in: 0...20),
            bearing: .constant(0),
            pitch: .random(in: 0...80))
        var options2 = options1
        verifyEqual(options1, options1)

        options2 = options1
        options2.padding?.top += .random(in: 1...10)
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.padding?.left += .random(in: 1...10)
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.padding?.bottom += .random(in: 1...10)
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.padding?.right += .random(in: 1...10)
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.zoom? += .random(in: 1...10)
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.bearing = .constant(.random(in: 1...10))
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.pitch? += .random(in: 1...10)
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
        options2.padding = .random()
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.zoom = .random(in: 1...10)
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.bearing = .constant(.random(in: 1...10))
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.pitch = .random(in: 1...10)
        verifyNotEqual(options1, options2)
    }
}
