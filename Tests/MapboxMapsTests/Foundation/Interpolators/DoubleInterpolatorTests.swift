import XCTest
@testable import MapboxMaps

final class DoubleInterpolatorTests: XCTestCase {
    func testInterpolate() {
        let interpolator = DoubleInterpolator()

        let fraction = 0.4

        XCTAssertEqual(interpolator.interpolate(from: 0, to: 0, fraction: fraction), 0)
        XCTAssertEqual(interpolator.interpolate(from: 0, to: 1, fraction: fraction), fraction)
        XCTAssertEqual(interpolator.interpolate(from: 0, to: 10, fraction: fraction), fraction * 10)
        XCTAssertEqual(interpolator.interpolate(from: 0, to: -1, fraction: fraction), -fraction)
        XCTAssertEqual(interpolator.interpolate(from: -1, to: 1, fraction: fraction), -1 + 2 * fraction)
    }
}
