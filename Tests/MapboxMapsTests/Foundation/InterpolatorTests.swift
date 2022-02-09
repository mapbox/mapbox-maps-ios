import XCTest
@testable import MapboxMaps

final class InterpolatorTests: XCTestCase {
    func testInterpolate() {
        let interpolator = Interpolator()

        let percent = Double.random(in: -1000...1000)

        XCTAssertEqual(interpolator.interpolate(from: 0, to: 0, percent: percent), 0)
        XCTAssertEqual(interpolator.interpolate(from: 0, to: 1, percent: percent), percent)
        XCTAssertEqual(interpolator.interpolate(from: 0, to: 10, percent: percent), percent * 10)
        XCTAssertEqual(interpolator.interpolate(from: 0, to: -1, percent: percent), -percent)
        XCTAssertEqual(interpolator.interpolate(from: -1, to: 1, percent: percent), -1 + 2 * percent)
    }
}

final class WrappingInterpolatorTests: XCTestCase {
    func testInterpolate() {
        let range: Range<Double> = 0..<360
        let interpolator = WrappingInterpolator(range: range)

        let percent = Double.random(in: -1000...1000)

        XCTAssertEqual(interpolator.interpolate(from: 0, to: 0, percent: percent), 0)
        XCTAssertEqual(interpolator.interpolate(from: 0, to: 1, percent: percent), percent.wrapped(to: range))
        XCTAssertEqual(interpolator.interpolate(from: 10, to: 20, percent: percent), (10 + 10 * percent).wrapped(to: range))
        XCTAssertEqual(interpolator.interpolate(from: 20, to: 10, percent: percent), (20 - 10 * percent).wrapped(to: range))
        XCTAssertEqual(interpolator.interpolate(from: 350, to: 10, percent: percent), (350 + 20 * percent).wrapped(to: range))
        XCTAssertEqual(interpolator.interpolate(from: 350, to: 370, percent: percent), (350 + 20 * percent).wrapped(to: range))
        XCTAssertEqual(interpolator.interpolate(from: 10, to: 350, percent: percent), (10 - 20 * percent).wrapped(to: range))
        XCTAssertEqual(interpolator.interpolate(from: 10, to: -10, percent: percent), (10 - 20 * percent).wrapped(to: range))
    }
}
