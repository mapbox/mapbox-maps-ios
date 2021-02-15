import XCTest
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

final class Comparable_ClampedTests: XCTestCase {
    func testClampedWithValueLessThanLowerBound() throws {
        let limits = 0...10
        let value = -1

        let actual = value.clamped(to: limits)

        XCTAssertEqual(actual, limits.lowerBound)
    }

    func testClampedWithValueGreaterThanUpperBound() throws {
        let limits = 0...10
        let value = 11

        let actual = value.clamped(to: limits)

        XCTAssertEqual(actual, limits.upperBound)
    }

    func testClampedWithValueWithinLimits() throws {
        let limits = 0...10
        let value = 5

        let actual = value.clamped(to: limits)

        XCTAssertEqual(actual, value)
    }
}
