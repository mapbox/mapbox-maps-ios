import XCTest
@testable import MapboxMaps

final class OptionalInterpolatorTests: XCTestCase {

    var doubleInterpolator: MockDoubleInterpolator!
    var optionalInterpolator: OptionalInterpolator!

    override func setUp() {
        super.setUp()
        doubleInterpolator = MockDoubleInterpolator()
        optionalInterpolator = OptionalInterpolator()
    }

    override func tearDown() {
        optionalInterpolator = nil
        doubleInterpolator = nil
        super.tearDown()
    }

    func testBothNil() {
        let result = optionalInterpolator.interpolate(
            from: nil,
            to: nil,
            fraction: .random(in: 0...1),
            interpolate: doubleInterpolator.interpolate(from:to:fraction:))

        XCTAssertNil(result)
        XCTAssertTrue(doubleInterpolator.interpolateStub.invocations.isEmpty)
    }

    func testFromNil() {
        let result = optionalInterpolator.interpolate(
            from: nil,
            to: Double.random(in: 0..<10),
            fraction: .random(in: 0...1),
            interpolate: doubleInterpolator.interpolate(from:to:fraction:))

        XCTAssertNil(result)
        XCTAssertTrue(doubleInterpolator.interpolateStub.invocations.isEmpty)
    }

    func testToNil() {
        let result = optionalInterpolator.interpolate(
            from: Double.random(in: 0..<10),
            to: nil,
            fraction: .random(in: 0...1),
            interpolate: doubleInterpolator.interpolate(from:to:fraction:))

        XCTAssertNil(result)
        XCTAssertTrue(doubleInterpolator.interpolateStub.invocations.isEmpty)
    }

    func testBothNonNil() throws {
        let from = Double.random(in: 0..<10)
        let to = Double.random(in: 0..<10)
        let fraction = Double.random(in: 0...1)

        let result = optionalInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction,
            interpolate: doubleInterpolator.interpolate(from:to:fraction:))

        XCTAssertEqual(doubleInterpolator.interpolateStub.invocations.count, 1)
        let interpolateInvocation = try XCTUnwrap(doubleInterpolator.interpolateStub.invocations.first)
        XCTAssertEqual(interpolateInvocation.parameters.from, from)
        XCTAssertEqual(interpolateInvocation.parameters.to, to)
        XCTAssertEqual(interpolateInvocation.parameters.fraction, fraction)
        XCTAssertEqual(result, interpolateInvocation.returnValue)
    }
}
