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
}
