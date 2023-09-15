@testable import MapboxMaps
import XCTest

final class CoreGraphicsTests: XCTestCase {
    func testPointArithmetic() {
        var point = CGPoint(x: 0, y: 0)
        point = point + CGPoint(x: 1, y: 2)
        point = point - CGPoint(x: -1, y: -2)
        XCTAssertEqual(point, CGPoint(x: 2, y: 4))
    }
}
