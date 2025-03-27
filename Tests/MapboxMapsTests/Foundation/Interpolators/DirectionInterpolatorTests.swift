@testable import MapboxMaps
import XCTest

final class DirectionInterpolatorTests: XCTestCase {
    var wrappingInterpolator: MockWrappingInterpolator!
    var directionInterpolator: DirectionInterpolator!

    override func setUp() {
        super.setUp()
        wrappingInterpolator = MockWrappingInterpolator()
        directionInterpolator = DirectionInterpolator(
            wrappingInterpolator: wrappingInterpolator)
    }

    override func tearDown() {
        directionInterpolator = nil
        wrappingInterpolator = nil
        super.tearDown()
    }

    func testInterpolate() {
        let from: Double = 123
        let to: Double = 300
        let fraction: Double = 0.4

        let result = directionInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction)

        XCTAssertEqual(wrappingInterpolator.interpolateStub.invocations, [
            .init(
                parameters: .init(
                    from: from,
                    to: to,
                    fraction: fraction,
                    range: 0..<360),
                returnValue: result)])
    }
}
