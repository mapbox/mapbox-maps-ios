@testable import MapboxMaps
import XCTest

final class LongitudeInterpolatorTests: XCTestCase {
    var wrappingInterpolator: MockWrappingInterpolator!
    var longitudeInterpolator: LongitudeInterpolator!

    override func setUp() {
        super.setUp()
        wrappingInterpolator = MockWrappingInterpolator()
        longitudeInterpolator = LongitudeInterpolator(
            wrappingInterpolator: wrappingInterpolator)
    }

    override func tearDown() {
        longitudeInterpolator = nil
        wrappingInterpolator = nil
        super.tearDown()
    }

    func testInterpolate() {
        let from: Double = -179
        let to: Double = 189
        let fraction: Double = 0.4

        let result = longitudeInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction)

        XCTAssertEqual(wrappingInterpolator.interpolateStub.invocations, [
            .init(
                parameters: .init(
                    from: from,
                    to: to,
                    fraction: fraction,
                    range: -180..<180),
                returnValue: result)])
    }
}
