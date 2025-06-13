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
}
