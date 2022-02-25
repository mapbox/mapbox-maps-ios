@testable import MapboxMaps
import XCTest

final class TimingCurveTests: XCTestCase {
    func testEaseInOut() {
        XCTAssertEqual(TimingCurve.easeInOut.p1, CGPoint(x: 0.42, y: 0))
        XCTAssertEqual(TimingCurve.easeInOut.p2, CGPoint(x: 0.58, y: 1))
    }
}
