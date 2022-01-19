import XCTest
import MapboxMaps

final class FollowPuckViewportStateOptionsTests: XCTestCase {
    func testInitializerDefaultParameters() {
        let options = FollowPuckViewportStateOptions()

        XCTAssertEqual(options.zoom, 15)
        XCTAssertEqual(options.pitch, 40)
        XCTAssertEqual(options.bearing, .constant(0))
        XCTAssertEqual(options.padding, .zero)
        XCTAssertEqual(options.animationDuration, 1)
    }

    func testInitializer() {
        let zoom = CGFloat.random(in: 0...20)
        let pitch = CGFloat.random(in: 0...80)
        let bearing = FollowPuckViewportStateBearing.random()
        let padding = UIEdgeInsets.random()
        let animationDuration = TimeInterval.random(in: 0...10)

        let options = FollowPuckViewportStateOptions(
            zoom: zoom,
            pitch: pitch,
            bearing: bearing,
            padding: padding,
            animationDuration: animationDuration)

        XCTAssertEqual(options.zoom, zoom)
        XCTAssertEqual(options.pitch, pitch)
        XCTAssertEqual(options.bearing, bearing)
        XCTAssertEqual(options.padding, padding)
        XCTAssertEqual(options.animationDuration, animationDuration)
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
        var options1 = FollowPuckViewportStateOptions.random()
        options1.bearing = .constant(0)
        var options2 = options1
        verifyEqual(options1, options1)

        options2 = options1
        options2.zoom += .random(in: 1...10)
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.pitch += .random(in: 1...10)
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.bearing = .constant(.random(in: 0...10))
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.padding.top += .random(in: 1...10)
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.padding.left += .random(in: 1...10)
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.padding.bottom += .random(in: 1...10)
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.padding.right += .random(in: 1...10)
        verifyNotEqual(options1, options2)

        options2 = options1
        options2.animationDuration += .random(in: 1...10)
        verifyNotEqual(options1, options2)
    }
}
