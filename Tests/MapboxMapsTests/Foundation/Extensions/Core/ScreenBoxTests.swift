import XCTest
@testable import MapboxMaps

final class ScreenBoxTests: XCTestCase {
    func testInitWithCGRect() {
        let rect = CGRect(
            x: 10,
            y: 0,
            width: 100,
            height: 0)

        let screenBox = CoreScreenBox(rect)

        XCTAssertEqual(screenBox.min, CoreScreenCoordinate(x: rect.minX, y: rect.minY))
        XCTAssertEqual(screenBox.max, CoreScreenCoordinate(x: rect.maxX, y: rect.maxY))
    }

    func testCGRectInitWithScreenBox() {
        let screenBox = CoreScreenBox(
            min: CoreScreenCoordinate(x: 10.0, y: 20.0),
            max: CoreScreenCoordinate(x: 110.0, y: 220.0))

        let rect = CGRect(screenBox)

        XCTAssertEqual(rect, CGRect(x: 10, y: 20, width: 100, height: 200))
    }

    func testCGRectScreenBoxRoundTrip() {
        let rect = CGRect(x: 5, y: 15, width: 30, height: 40)

        XCTAssertEqual(CGRect(CoreScreenBox(rect)), rect)
    }
}
