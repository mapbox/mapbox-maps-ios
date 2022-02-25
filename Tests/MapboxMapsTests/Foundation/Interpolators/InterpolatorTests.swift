import XCTest
@testable import MapboxMaps

final class InterpolatorTests: XCTestCase {
    func testInterpolate() {
        let interpolator = Interpolator()

        let fraction = Double.random(in: -1000...1000)

        XCTAssertEqual(interpolator.interpolate(from: 0, to: 0, fraction: fraction), 0)
        XCTAssertEqual(interpolator.interpolate(from: 0, to: 1, fraction: fraction), fraction)
        XCTAssertEqual(interpolator.interpolate(from: 0, to: 10, fraction: fraction), fraction * 10)
        XCTAssertEqual(interpolator.interpolate(from: 0, to: -1, fraction: fraction), -fraction)
        XCTAssertEqual(interpolator.interpolate(from: -1, to: 1, fraction: fraction), -1 + 2 * fraction)
    }
}

final class WrappingInterpolatorTests: XCTestCase {
    func testInterpolate() {
        let range: Range<Double> = 0..<360
        let interpolator = WrappingInterpolator(range: range)

        let fraction = Double.random(in: -1000...1000)

        XCTAssertEqual(interpolator.interpolate(from: 0, to: 0, fraction: fraction), 0)
        XCTAssertEqual(interpolator.interpolate(from: 0, to: 1, fraction: fraction), fraction.wrapped(to: range))
        XCTAssertEqual(interpolator.interpolate(from: 10, to: 20, fraction: fraction), (10 + 10 * fraction).wrapped(to: range))
        XCTAssertEqual(interpolator.interpolate(from: 20, to: 10, fraction: fraction), (20 - 10 * fraction).wrapped(to: range))
        XCTAssertEqual(interpolator.interpolate(from: 350, to: 10, fraction: fraction), (350 + 20 * fraction).wrapped(to: range))
        XCTAssertEqual(interpolator.interpolate(from: 350, to: 370, fraction: fraction), (350 + 20 * fraction).wrapped(to: range))
        XCTAssertEqual(interpolator.interpolate(from: 10, to: 350, fraction: fraction), (10 - 20 * fraction).wrapped(to: range))
        XCTAssertEqual(interpolator.interpolate(from: 10, to: -10, fraction: fraction), (10 - 20 * fraction).wrapped(to: range))
    }
}
