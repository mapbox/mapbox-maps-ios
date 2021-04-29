import XCTest
@testable import MapboxMaps

final class ScreenBoxTests: XCTestCase {
    func testInitWithCGRect() {
        let rect = CGRect(
            x: CGFloat.random(in: 0...100),
            y: CGFloat.random(in: 0...100),
            width: CGFloat.random(in: 0...100),
            height: CGFloat.random(in: 0...100))

        let screenBox = ScreenBox(rect)

        XCTAssertEqual(screenBox.min, ScreenCoordinate(x: rect.minX, y: rect.minY))
        XCTAssertEqual(screenBox.max, ScreenCoordinate(x: rect.maxX, y: rect.maxY))
    }
}
