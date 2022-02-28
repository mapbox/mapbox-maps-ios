@testable import MapboxMaps
import XCTest

final class CoordinateInterpolatorTests: XCTestCase {

    var doubleInterpolator: MockDoubleInterpolator!
    var longitudeInterpolator: MockLongitudeInterpolator!
    var coordinateInterpolator: CoordinateInterpolator!

    override func setUp() {
        super.setUp()
        doubleInterpolator = MockDoubleInterpolator()
        longitudeInterpolator = MockLongitudeInterpolator()
        coordinateInterpolator = CoordinateInterpolator(
            doubleInterpolator: doubleInterpolator,
            longitudeInterpolator: longitudeInterpolator)
    }

    override func tearDown() {
        coordinateInterpolator = nil
        longitudeInterpolator = nil
        doubleInterpolator = nil
        super.tearDown()
    }

    func testInterpolate() throws {
        let from = CLLocationCoordinate2D.random()
        let to = CLLocationCoordinate2D.random()
        let fraction = Double.random(in: 0...1)
        doubleInterpolator.interpolateStub.defaultReturnValue = .random(in: 0..<100)
        longitudeInterpolator.interpolateStub.defaultReturnValue = .random(in: 0..<100)

        let result = coordinateInterpolator.interpolate(from: from, to: to, fraction: fraction)

        XCTAssertEqual(doubleInterpolator.interpolateStub.invocations.count, 1)
        let interpolateInvocation = try XCTUnwrap(doubleInterpolator.interpolateStub.invocations.first)
        XCTAssertEqual(interpolateInvocation.parameters.from, from.latitude)
        XCTAssertEqual(interpolateInvocation.parameters.to, to.latitude)
        XCTAssertEqual(interpolateInvocation.parameters.fraction, fraction)
        XCTAssertEqual(interpolateInvocation.returnValue, result.latitude)

        XCTAssertEqual(longitudeInterpolator.interpolateStub.invocations.count, 1)
        let longitudeInterpolateInvocation = try XCTUnwrap(longitudeInterpolator.interpolateStub.invocations.first)
        XCTAssertEqual(longitudeInterpolateInvocation.parameters.from, from.longitude)
        XCTAssertEqual(longitudeInterpolateInvocation.parameters.to, to.longitude)
        XCTAssertEqual(longitudeInterpolateInvocation.parameters.fraction, fraction)
        XCTAssertEqual(longitudeInterpolateInvocation.returnValue, result.longitude)
    }
}
