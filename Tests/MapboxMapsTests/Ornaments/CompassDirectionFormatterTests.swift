import CoreLocation
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsOrnaments
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class CompassDirectionFormatterTests: XCTestCase {

    //swiftlint:disable function_body_length
    func testCompassDirections() {
        let shortFormatter = CompassDirectionFormatter()
        shortFormatter.unitStyle = .short
        let mediumFormatter = CompassDirectionFormatter()
        let longFormatter = CompassDirectionFormatter()
        longFormatter.unitStyle = .long

        var direction: CLLocationDirection

        direction = -45
        XCTAssertEqual("NW", shortFormatter.string(from: direction))
        XCTAssertEqual("northwest", mediumFormatter.string(from: direction))
        XCTAssertEqual("northwest", longFormatter.string(from: direction))

        direction = 0
        XCTAssertEqual("N", shortFormatter.string(from: direction))
        XCTAssertEqual("north", mediumFormatter.string(from: direction))
        XCTAssertEqual("north", longFormatter.string(from: direction))

        direction = 1
        XCTAssertEqual("N", shortFormatter.string(from: direction))
        XCTAssertEqual("north", mediumFormatter.string(from: direction))
        XCTAssertEqual("north", longFormatter.string(from: direction))

        direction = 10
        XCTAssertEqual("NbE", shortFormatter.string(from: direction))
        XCTAssertEqual("north by east", mediumFormatter.string(from: direction))
        XCTAssertEqual("north by east", longFormatter.string(from: direction))

        direction = 20
        XCTAssertEqual("NNE", shortFormatter.string(from: direction))
        XCTAssertEqual("north-northeast", mediumFormatter.string(from: direction))
        XCTAssertEqual("north-northeast", longFormatter.string(from: direction))

        direction = 45
        XCTAssertEqual("NE", shortFormatter.string(from: direction))
        XCTAssertEqual("northeast", mediumFormatter.string(from: direction))
        XCTAssertEqual("northeast", longFormatter.string(from: direction))

        direction = 90
        XCTAssertEqual("E", shortFormatter.string(from: direction))
        XCTAssertEqual("east", mediumFormatter.string(from: direction))
        XCTAssertEqual("east", longFormatter.string(from: direction))

        direction = 180
        XCTAssertEqual("S", shortFormatter.string(from: direction))
        XCTAssertEqual("south", mediumFormatter.string(from: direction))
        XCTAssertEqual("south", longFormatter.string(from: direction))

        direction = 270
        XCTAssertEqual("W", shortFormatter.string(from: direction))
        XCTAssertEqual("west", mediumFormatter.string(from: direction))
        XCTAssertEqual("west", longFormatter.string(from: direction))

        direction = 359.34951805867024
        XCTAssertEqual("N", shortFormatter.string(from: direction))
        XCTAssertEqual("north", mediumFormatter.string(from: direction))
        XCTAssertEqual("north", longFormatter.string(from: direction))

        direction = 360
        XCTAssertEqual("N", shortFormatter.string(from: direction))
        XCTAssertEqual("north", mediumFormatter.string(from: direction))
        XCTAssertEqual("north", longFormatter.string(from: direction))

        direction = 360.1
        XCTAssertEqual("N", shortFormatter.string(from: direction))
        XCTAssertEqual("north", mediumFormatter.string(from: direction))
        XCTAssertEqual("north", longFormatter.string(from: direction))

        direction = 720
        XCTAssertEqual("N", shortFormatter.string(from: direction))
        XCTAssertEqual("north", mediumFormatter.string(from: direction))
        XCTAssertEqual("north", longFormatter.string(from: direction))
    }
}
