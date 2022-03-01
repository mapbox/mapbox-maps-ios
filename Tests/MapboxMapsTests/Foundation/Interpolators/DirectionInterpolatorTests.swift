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
        let from = CLLocationDirection.random(in: 0..<360)
        let to = CLLocationDirection.random(in: 0..<360)
        let fraction = Double.random(in: 0...1)

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
