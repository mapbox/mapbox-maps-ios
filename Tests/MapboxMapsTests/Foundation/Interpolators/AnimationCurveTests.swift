@testable import MapboxMaps
import XCTest

final class AnimationCurveTests: XCTestCase {
    func testEaseInOut() {
        XCTAssertEqual(TimingCurve.easeInOut.p1, CGPoint(x: 0.42, y: 0))
        XCTAssertEqual(TimingCurve.easeInOut.p2, CGPoint(x: 0.58, y: 1))
    }

    func testEaseIn() {
        XCTAssertEqual(TimingCurve.easeIn.p1, CGPoint(x: 0.58, y: 0))
        XCTAssertEqual(TimingCurve.easeIn.p2, CGPoint(x: 1, y: 1))
    }

    func testEaseOut() {
        XCTAssertEqual(TimingCurve.easeOut.p1, CGPoint(x: 0, y: 0))
        XCTAssertEqual(TimingCurve.easeOut.p2, CGPoint(x: 0.42, y: 1))
    }

    func testLinear() {
        XCTAssertEqual(TimingCurve.linear.p1, CGPoint(x: 0, y: 0))
        XCTAssertEqual(TimingCurve.linear.p2, CGPoint(x: 1, y: 1))
    }
}
