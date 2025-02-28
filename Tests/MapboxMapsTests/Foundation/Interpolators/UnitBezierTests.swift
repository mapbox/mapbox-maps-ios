@testable import MapboxMaps
import XCTest

final class UnitBezierTests: XCTestCase {

    func testLinear() {
        let unitBezier = UnitBezier(p1: .zero, p2: .init(x: 1, y: 1))

        let x = Double.random(in: 0...1)

        XCTAssertEqual(unitBezier.solve(x, 1e-6), x, accuracy: 1e-6)
    }

    func testEaseInOut() {
        let unitBezier = UnitBezier(
            p1: .init(x: 0.42, y: 0),
            p2: .init(x: 0.58, y: 1))

        XCTAssertEqual(unitBezier.solve(0, 1e-6), 0, accuracy: 1e-6)
        XCTAssertEqual(unitBezier.solve(0.25, 1e-6), 0.13, accuracy: 1)
        XCTAssertEqual(unitBezier.solve(0.5, 1e-6), 0.5, accuracy: 1e-6)
        XCTAssertEqual(unitBezier.solve(0.75, 1e-6), 0.87, accuracy: 1)
        XCTAssertEqual(unitBezier.solve(1, 1e-6), 1, accuracy: 1e-6)
    }

    func testBisectionMethod() {
        let unitBezier = UnitBezier(
            p1: .init(x: 0, y: 100000),
            p2: .init(x: 0, y: 100000))

        XCTAssertEqual(unitBezier.solve(0, 0), 0, accuracy: 1e-2)
    }
}
