@testable import MapboxMaps
import XCTest

final class WrappingInterpolatorTests: XCTestCase {
    func testInterpolate() {
        let range: Range<Double> = 0..<360
        let interpolator = WrappingInterpolator()

        let fraction = Double.random(in: -1000...1000)

        func interpolate(from: Double, to: Double) -> Double {
            return interpolator.interpolate(
                from: from,
                to: to,
                fraction: fraction,
                range: range)
        }

        XCTAssertEqual(interpolate(from: 0, to: 0), 0)
        XCTAssertEqual(interpolate(from: 0, to: 1), fraction.wrapped(to: range))
        XCTAssertEqual(interpolate(from: 10, to: 20), (10 + 10 * fraction).wrapped(to: range))
        XCTAssertEqual(interpolate(from: 20, to: 10), (20 - 10 * fraction).wrapped(to: range))
        XCTAssertEqual(interpolate(from: 350, to: 10), (350 + 20 * fraction).wrapped(to: range))
        XCTAssertEqual(interpolate(from: 350, to: 370), (350 + 20 * fraction).wrapped(to: range))
        XCTAssertEqual(interpolate(from: 10, to: 350), (10 - 20 * fraction).wrapped(to: range))
        XCTAssertEqual(interpolate(from: 10, to: -10), (10 - 20 * fraction).wrapped(to: range))
    }
}
