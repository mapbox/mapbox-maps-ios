import XCTest
@testable import MapboxMaps

final class FloatingPointTests: XCTestCase {
    func testWrappedWithZeroLowerBound() {
        XCTAssertEqual((-361).wrapped(to: 0..<360), 359)
        XCTAssertEqual((-360).wrapped(to: 0..<360), 0)
        XCTAssertEqual((-359).wrapped(to: 0..<360), 1)

        XCTAssertEqual((-1).wrapped(to: 0..<360), 359)
        XCTAssertEqual(0.wrapped(to: 0..<360), 0)
        XCTAssertEqual(1.wrapped(to: 0..<360), 1)

        XCTAssertEqual(359.wrapped(to: 0..<360), 359)
        XCTAssertEqual(360.wrapped(to: 0..<360), 0)
        XCTAssertEqual(361.wrapped(to: 0..<360), 1)

        XCTAssertEqual(719.wrapped(to: 0..<360), 359)
        XCTAssertEqual(720.wrapped(to: 0..<360), 0)
        XCTAssertEqual(721.wrapped(to: 0..<360), 1)
    }

    func testWrappedWithPositiveLowerBound() {
        XCTAssertEqual((-4).wrapped(to: 1..<5), 4)
        XCTAssertEqual((-3).wrapped(to: 1..<5), 1)
        XCTAssertEqual((-2).wrapped(to: 1..<5), 2)

        XCTAssertEqual(0.wrapped(to: 1..<5), 4)
        XCTAssertEqual(1.wrapped(to: 1..<5), 1)
        XCTAssertEqual(2.wrapped(to: 1..<5), 2)

        XCTAssertEqual(4.wrapped(to: 1..<5), 4)
        XCTAssertEqual(5.wrapped(to: 1..<5), 1)
        XCTAssertEqual(6.wrapped(to: 1..<5), 2)

        XCTAssertEqual(8.wrapped(to: 1..<5), 4)
        XCTAssertEqual(9.wrapped(to: 1..<5), 1)
        XCTAssertEqual(10.wrapped(to: 1..<5), 2)
    }

    func testWrappedWithNegativeLowerBound() {
        XCTAssertEqual((-7).wrapped(to: -2..<2), 1)
        XCTAssertEqual((-6).wrapped(to: -2..<2), -2)
        XCTAssertEqual((-5).wrapped(to: -2..<2), -1)

        XCTAssertEqual((-3).wrapped(to: -2..<2), 1)
        XCTAssertEqual((-2).wrapped(to: -2..<2), -2)
        XCTAssertEqual((-1).wrapped(to: -2..<2), -1)

        XCTAssertEqual(1.wrapped(to: -2..<2), 1)
        XCTAssertEqual(2.wrapped(to: -2..<2), -2)
        XCTAssertEqual(3.wrapped(to: -2..<2), -1)

        XCTAssertEqual(5.wrapped(to: -2..<2), 1)
        XCTAssertEqual(6.wrapped(to: -2..<2), -2)
        XCTAssertEqual(7.wrapped(to: -2..<2), -1)
    }

    func testToDegrees() {
        XCTAssertEqual(0.toDegrees(), 0)
        XCTAssertEqual((Double.pi / 4).toDegrees(), 45, accuracy: 1e-8)
        XCTAssertEqual((Double.pi / 2).toDegrees(), 90, accuracy: 1e-8)
        XCTAssertEqual((3 * Double.pi / 4).toDegrees(), 135, accuracy: 1e-8)
        XCTAssertEqual(Double.pi.toDegrees(), 180, accuracy: 1e-8)
        XCTAssertEqual((2 * Double.pi).toDegrees(), 360, accuracy: 1e-8)
        XCTAssertEqual((-2 * Double.pi).toDegrees(), -360, accuracy: 1e-8)
        XCTAssertEqual((4 * Double.pi).toDegrees(), 720, accuracy: 1e-8)
    }

    func testWrappedAngleWithoutChange() {
        let anyAngle = CGFloat.random(in: 0..<2 * .pi)
        XCTAssertEqual(anyAngle.wrappedAngle(to: anyAngle), 0)
    }

    func testWrappedAngleLargeNegativeRotation() {
        // just greater than -2 pi; result should wrap to being just greater than 0
        let rotation = 0.wrappedAngle(to: -(2 * .pi) + 1e-8)

        // value should be just greater than 0
        XCTAssertGreaterThan(rotation, 0)
        XCTAssertEqual(rotation, 0, accuracy: 1e-6)
    }

    func testWrappedAngleSmallNegativeRotation() {
        let rotation = 0.wrappedAngle(to: -1e-8)

        // value should be just less than 2pi
        XCTAssertLessThan(rotation, 2 * .pi)
        XCTAssertEqual(rotation, 2 * .pi, accuracy: 1e-6)
    }

    func testWrappedAngleLargePositiveRotation() {
        // just less than 2 pi
        let rotation = 0.wrappedAngle(to: (2 * .pi) - 1e-8)

        // value should be just less than 2pi
        XCTAssertLessThan(rotation, 2 * .pi)
        XCTAssertEqual(rotation, 2 * .pi, accuracy: 1e-6)
    }

    func testWrappedAngleSmallPositiveRotation() {
        let rotation = 0.wrappedAngle(to: 1e-8)

        // value should be just greater than 0
        XCTAssertGreaterThan(rotation, 0)
        XCTAssertEqual(rotation, 0, accuracy: 1e-6)
    }
}
