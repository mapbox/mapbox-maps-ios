import XCTest
@testable import MapboxMaps

final class LocationInterpolatorTests: XCTestCase {

    var interpolator: MockInterpolator!
    var directionInterpolator: MockInterpolator!
    var latitudeInterpolator: MockInterpolator!
    var locationInterpolator: LocationInterpolator!
    var from: InterpolatedLocation!
    var to: InterpolatedLocation!
    var percent: Double!

    override func setUp() {
        super.setUp()
        interpolator = MockInterpolator()
        directionInterpolator = MockInterpolator()
        latitudeInterpolator = MockInterpolator()
        locationInterpolator = LocationInterpolator(
            interpolator: interpolator,
            directionInterpolator: directionInterpolator,
            latitudeInterpolator: latitudeInterpolator)
        from = .random()
        to = .random()
        percent = .random(in: -10...10)

        interpolator.interpolateStub.returnValueQueue = .random(
            withLength: 3,
            generator: { .random(in: -200...200) })
    }

    override func tearDown() {
        percent = nil
        to = nil
        from = nil
        locationInterpolator = nil
        latitudeInterpolator = nil
        directionInterpolator = nil
        interpolator = nil
        super.tearDown()
    }

    func verifyCommonCases(withResult result: InterpolatedLocation) {
        XCTAssertEqual(latitudeInterpolator.interpolateStub.invocations.count, 1)
        XCTAssertEqual(interpolator.interpolateStub.invocations.count, 3)

        guard latitudeInterpolator.interpolateStub.invocations.count == 1,
              interpolator.interpolateStub.invocations.count == 3 else {
            return
        }

        let latitudeInterpolateInvocation = latitudeInterpolator.interpolateStub.invocations[0]
        XCTAssertEqual(latitudeInterpolateInvocation.parameters.from, from.coordinate.latitude)
        XCTAssertEqual(latitudeInterpolateInvocation.parameters.to, to.coordinate.latitude)
        XCTAssertEqual(latitudeInterpolateInvocation.parameters.percent, percent)
        XCTAssertEqual(result.coordinate.latitude, latitudeInterpolateInvocation.returnValue)

        let longitudeInterpolateInvocation = interpolator.interpolateStub.invocations[0]
        XCTAssertEqual(longitudeInterpolateInvocation.parameters.from, from.coordinate.longitude)
        XCTAssertEqual(longitudeInterpolateInvocation.parameters.to, to.coordinate.longitude)
        XCTAssertEqual(longitudeInterpolateInvocation.parameters.percent, percent)
        XCTAssertEqual(result.coordinate.longitude, longitudeInterpolateInvocation.returnValue)

        let altitudeInterpolateInvocation = interpolator.interpolateStub.invocations[1]
        XCTAssertEqual(altitudeInterpolateInvocation.parameters.from, from.altitude)
        XCTAssertEqual(altitudeInterpolateInvocation.parameters.to, to.altitude)
        XCTAssertEqual(altitudeInterpolateInvocation.parameters.percent, percent)
        XCTAssertEqual(result.altitude, altitudeInterpolateInvocation.returnValue)

        let horizontalAccuracyInterpolateInvocation = interpolator.interpolateStub.invocations[2]
        XCTAssertEqual(horizontalAccuracyInterpolateInvocation.parameters.from, from.horizontalAccuracy)
        XCTAssertEqual(horizontalAccuracyInterpolateInvocation.parameters.to, to.horizontalAccuracy)
        XCTAssertEqual(horizontalAccuracyInterpolateInvocation.parameters.percent, percent)
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
            percent: percent)

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
            percent: percent)

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
            percent: percent)

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
            percent: percent)

        verifyCommonCases(withResult: location)

        XCTAssertEqual(directionInterpolator.interpolateStub.invocations.count, 2)

        guard directionInterpolator.interpolateStub.invocations.count == 2 else {
            return
        }

        let courseInterpolateInvocation = directionInterpolator.interpolateStub.invocations[0]
        XCTAssertEqual(courseInterpolateInvocation.parameters.from, from.course)
        XCTAssertEqual(courseInterpolateInvocation.parameters.to, to.course)
        XCTAssertEqual(courseInterpolateInvocation.parameters.percent, percent)
        XCTAssertEqual(location.course, courseInterpolateInvocation.returnValue)

        let headingInterpolateInvocation = directionInterpolator.interpolateStub.invocations[1]
        XCTAssertEqual(headingInterpolateInvocation.parameters.from, from.heading)
        XCTAssertEqual(headingInterpolateInvocation.parameters.to, to.heading)
        XCTAssertEqual(headingInterpolateInvocation.parameters.percent, percent)
        XCTAssertEqual(location.heading, headingInterpolateInvocation.returnValue)
    }
}
