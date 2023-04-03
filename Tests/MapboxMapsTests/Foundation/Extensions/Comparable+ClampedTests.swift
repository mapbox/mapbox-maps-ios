import XCTest
@testable import MapboxMaps

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

    func testClamp() {
        var value: Double = 5

        // No clamping
        XCTAssertFalse(value.clamp(to: 0...6))
        XCTAssertFalse(value.clamp(to: 0...5))

        // Clamps by upper bound to 4
        XCTAssertTrue(value.clamp(to: 0...4))
        XCTAssertEqual(value, 4)

        // No clamping
        XCTAssertFalse(value.clamp(to: 4...5))

        // Clamps by lower bound to 4.5
        XCTAssertTrue(value.clamp(to: 4.5...5))
        XCTAssertEqual(value, 4.5)
    }
}
