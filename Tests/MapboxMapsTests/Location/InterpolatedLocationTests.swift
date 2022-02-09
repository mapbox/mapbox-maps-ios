import XCTest
@testable import MapboxMaps

final class InterpolatedLocationTests: XCTestCase {

    func testInitWithLocation() {
        let coordinate = CLLocationCoordinate2D.random()
        let altitude = CLLocationDistance.random(in: 0..<10)
        let horizontalAccuracy = CLLocationAccuracy.random(in: 0..<100)
        let course = CLLocationDirection.random(in: 0..<360)

        let heading: MockHeading? = .random({
            let heading = MockHeading()
            heading.trueHeadingStub.defaultReturnValue = .random(in: 0..<360)
            heading.magneticHeadingStub.defaultReturnValue = .random(in: 0..<360)
            return heading
        }())

        let accuracyAuthorization = CLAccuracyAuthorization.random()

        let location = Location(
            location: CLLocation(
                coordinate: coordinate,
                altitude: altitude,
                horizontalAccuracy: horizontalAccuracy,
                verticalAccuracy: .random(in: 0..<10),
                course: course,
                speed: .random(in: 0..<10),
                timestamp: Date(timeIntervalSinceReferenceDate: 0)),
            heading: heading,
            accuracyAuthorization: accuracyAuthorization)

        let interpolatedLocation = InterpolatedLocation(location: location)

        XCTAssertEqual(interpolatedLocation.coordinate, coordinate)
        XCTAssertEqual(interpolatedLocation.altitude, altitude)
        XCTAssertEqual(interpolatedLocation.horizontalAccuracy, horizontalAccuracy)
        XCTAssertEqual(interpolatedLocation.course, course)
        XCTAssertEqual(interpolatedLocation.heading, location.headingDirection)
        XCTAssertEqual(interpolatedLocation.accuracyAuthorization, accuracyAuthorization)
    }

    func testInitWithLocationWithInvalidCourse() {
        let heading: MockHeading? = .random({
            let heading = MockHeading()
            heading.trueHeadingStub.defaultReturnValue = .random(in: 0..<360)
            heading.magneticHeadingStub.defaultReturnValue = .random(in: 0..<360)
            return heading
        }())

        let location = Location(
            location: CLLocation(
                coordinate: .random(),
                altitude: .random(in: 0..<10),
                horizontalAccuracy: .random(in: 0..<100),
                verticalAccuracy: .random(in: 0..<10),
                course: -1,
                speed: .random(in: 0..<10),
                timestamp: Date(timeIntervalSinceReferenceDate: 0)),
            heading: heading,
            accuracyAuthorization: .random())

        let interpolatedLocation = InterpolatedLocation(location: location)

        XCTAssertNil(interpolatedLocation.course)
    }

    func testMemberwiseInit() {
        let coordinate = CLLocationCoordinate2D.random()
        let altitude = CLLocationDistance.random(in: 0..<100)
        let horizontalAccuracy = CLLocationAccuracy.random(in: 0..<10)
        let course = CLLocationDirection?.random(.random(in: 0..<360))
        let heading = CLLocationDirection?.random(.random(in: 0..<360))
        let accuracyAuthorization = CLAccuracyAuthorization.random()

        let location = InterpolatedLocation(
            coordinate: coordinate,
            altitude: altitude,
            horizontalAccuracy: horizontalAccuracy,
            course: course,
            heading: heading,
            accuracyAuthorization: accuracyAuthorization)

        XCTAssertEqual(location.coordinate, coordinate)
        XCTAssertEqual(location.altitude, altitude)
        XCTAssertEqual(location.horizontalAccuracy, horizontalAccuracy)
        XCTAssertEqual(location.course, course)
        XCTAssertEqual(location.heading, heading)
        XCTAssertEqual(location.accuracyAuthorization, accuracyAuthorization)
    }
}
