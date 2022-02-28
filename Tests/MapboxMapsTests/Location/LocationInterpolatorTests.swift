import XCTest
@testable import MapboxMaps

final class LocationInterpolatorTests: XCTestCase {

    var interpolator: MockInterpolator!
    var directionInterpolator: MockDirectionInterpolator!
    var coordinateInterpolator: MockCoordinateInterpolator!
    var locationInterpolator: LocationInterpolator!
    var from: InterpolatedLocation!
    var to: InterpolatedLocation!
    var fraction: Double!

    override func setUp() {
        super.setUp()
        interpolator = MockInterpolator()
        directionInterpolator = MockDirectionInterpolator()
        coordinateInterpolator = MockCoordinateInterpolator()
        locationInterpolator = LocationInterpolator(
            interpolator: interpolator,
            directionInterpolator: directionInterpolator,
            coordinateInterpolator: coordinateInterpolator)
        from = .random()
        to = .random()
        fraction = .random(in: -10...10)

        interpolator.interpolateStub.returnValueQueue = .random(
            withLength: 3,
            generator: { .random(in: -200...200) })
        directionInterpolator.interpolateStub.returnValueQueue = .random(
            withLength: 2,
            generator: { .random(in: 0..<360) })
        coordinateInterpolator.interpolateStub.defaultReturnValue = .random()
    }

    override func tearDown() {
        fraction = nil
        to = nil
        from = nil
        locationInterpolator = nil
        coordinateInterpolator = nil
        directionInterpolator = nil
        interpolator = nil
        super.tearDown()
    }

    func verifyCommonCases(withResult result: InterpolatedLocation) {
        XCTAssertEqual(coordinateInterpolator.interpolateStub.invocations.count, 1)
        XCTAssertEqual(interpolator.interpolateStub.invocations.count, 2)

        guard coordinateInterpolator.interpolateStub.invocations.count == 1,
              interpolator.interpolateStub.invocations.count == 2 else {
            return
        }

        let coordinateInterpolateInvocation = coordinateInterpolator.interpolateStub.invocations[0]
        XCTAssertEqual(coordinateInterpolateInvocation.parameters.from, from.coordinate)
        XCTAssertEqual(coordinateInterpolateInvocation.parameters.to, to.coordinate)
        XCTAssertEqual(coordinateInterpolateInvocation.parameters.fraction, fraction)
        XCTAssertEqual(result.coordinate, coordinateInterpolateInvocation.returnValue)

        let altitudeInterpolateInvocation = interpolator.interpolateStub.invocations[0]
        XCTAssertEqual(altitudeInterpolateInvocation.parameters.from, from.altitude)
        XCTAssertEqual(altitudeInterpolateInvocation.parameters.to, to.altitude)
        XCTAssertEqual(altitudeInterpolateInvocation.parameters.fraction, fraction)
        XCTAssertEqual(result.altitude, altitudeInterpolateInvocation.returnValue)

        let horizontalAccuracyInterpolateInvocation = interpolator.interpolateStub.invocations[1]
        XCTAssertEqual(horizontalAccuracyInterpolateInvocation.parameters.from, from.horizontalAccuracy)
        XCTAssertEqual(horizontalAccuracyInterpolateInvocation.parameters.to, to.horizontalAccuracy)
        XCTAssertEqual(horizontalAccuracyInterpolateInvocation.parameters.fraction, fraction)
        XCTAssertEqual(result.horizontalAccuracy, horizontalAccuracyInterpolateInvocation.returnValue)

        XCTAssertEqual(result.accuracyAuthorization, to.accuracyAuthorization)
    }

    func testInterpolateWithNilFromCourseAndFromHeading() {
        from.course = nil
        from.heading = nil
        to.course = .random(in: 0..<360)
        to.heading = .random(in: 0..<360)

        let location = locationInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction)

        verifyCommonCases(withResult: location)

        XCTAssertEqual(directionInterpolator.interpolateStub.invocations.count, 0)
        XCTAssertEqual(location.course, to.course)
        XCTAssertEqual(location.heading, to.heading)
    }

    func testInterpolateWithNilToCourseAndToHeading() {
        from.course = .random(in: 0..<360)
        from.heading = .random(in: 0..<360)
        to.course = nil
        to.heading = nil

        let location = locationInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction)

        verifyCommonCases(withResult: location)

        XCTAssertEqual(directionInterpolator.interpolateStub.invocations.count, 0)
        XCTAssertNil(location.course)
        XCTAssertNil(location.heading)
    }

    func testInterpolateWithNilToAndFromCourseAndToAndFromHeading() {
        from.course = nil
        from.heading = nil
        to.course = nil
        to.heading = nil

        let location = locationInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction)

        verifyCommonCases(withResult: location)

        XCTAssertEqual(directionInterpolator.interpolateStub.invocations.count, 0)
        XCTAssertNil(location.course)
        XCTAssertNil(location.heading)
    }

    func testInterpolateWithNonNilCourseAndHeading() {
        from.course = .random(in: 0..<360)
        from.heading = .random(in: 0..<360)
        to.course = .random(in: 0..<360)
        to.heading = .random(in: 0..<360)

        let location = locationInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fraction)

        verifyCommonCases(withResult: location)

        XCTAssertEqual(directionInterpolator.interpolateStub.invocations.count, 2)

        guard directionInterpolator.interpolateStub.invocations.count == 2 else {
            return
        }

        let courseInterpolateInvocation = directionInterpolator.interpolateStub.invocations[0]
        XCTAssertEqual(courseInterpolateInvocation.parameters.from, from.course)
        XCTAssertEqual(courseInterpolateInvocation.parameters.to, to.course)
        XCTAssertEqual(courseInterpolateInvocation.parameters.fraction, fraction)
        XCTAssertEqual(location.course, courseInterpolateInvocation.returnValue)

        let headingInterpolateInvocation = directionInterpolator.interpolateStub.invocations[1]
        XCTAssertEqual(headingInterpolateInvocation.parameters.from, from.heading)
        XCTAssertEqual(headingInterpolateInvocation.parameters.to, to.heading)
        XCTAssertEqual(headingInterpolateInvocation.parameters.fraction, fraction)
        XCTAssertEqual(location.heading, headingInterpolateInvocation.returnValue)
    }
}
