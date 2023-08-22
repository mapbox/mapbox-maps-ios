import CoreLocation
import XCTest
import MapboxMaps

final class CompassDirectionFormatterTests: XCTestCase {

    var formatter: CompassDirectionFormatter!

    override func setUp() {
        super.setUp()
        formatter = CompassDirectionFormatter()
    }

    override func tearDown() {
        formatter = nil
        super.tearDown()
    }

    func verifyString(with direction: CLLocationDirection, short: String, long: String, line: UInt = #line) {
        formatter.style = .short
        XCTAssertEqual(short, formatter.string(from: direction), line: line)
        formatter.style = .long
        XCTAssertEqual(long, formatter.string(from: direction), line: line)
    }

    func testCompassDirections() {
        verifyString(with: -45, short: "NW", long: "northwest")
        verifyString(with: 0, short: "N", long: "north")
        verifyString(with: 1, short: "N", long: "north")
        verifyString(with: 10, short: "NbE", long: "north by east")
        verifyString(with: 20, short: "NNE", long: "north-northeast")
        verifyString(with: 45, short: "NE", long: "northeast")
        verifyString(with: 90, short: "E", long: "east")
        verifyString(with: 180, short: "S", long: "south")
        verifyString(with: 270, short: "W", long: "west")
        verifyString(with: 359.34951805867024, short: "N", long: "north")
        verifyString(with: 360, short: "N", long: "north")
        verifyString(with: 360.1, short: "N", long: "north")
        verifyString(with: 720, short: "N", long: "north")    }
}
