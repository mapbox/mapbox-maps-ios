import XCTest
import MapboxMaps

final class LocationTests: XCTestCase {

    func makeCLLocation(coordinate: CLLocationCoordinate2D = .random(),
                        horizontalAccuracy: CLLocationAccuracy = .random(in: 0..<10),
                        course: CLLocationDirection = .random(in: 0..<360)) -> CLLocation {
        CLLocation(
            coordinate: coordinate,
            altitude: 0,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: 0,
            course: course,
            speed: 0,
            timestamp: Date())
    }

    func testInitWithLocationAndHeading() {
        let clLocation = makeCLLocation()
        let heading = CLHeading()

        let location = Location(with: clLocation, heading: heading)

        XCTAssertTrue(location.location === clLocation)
        XCTAssertTrue(location.heading === heading)
        XCTAssertEqual(location.accuracyAuthorization, .fullAccuracy)
    }

    func testInitWithLocationAndNilHeading() {
        let clLocation = makeCLLocation()

        let location = Location(with: clLocation, heading: nil)

        XCTAssertTrue(location.location === clLocation)
        XCTAssertNil(location.heading)
        XCTAssertEqual(location.accuracyAuthorization, .fullAccuracy)
    }

    func testInitWithLocationHeadingAndAccuracyAuthorization() {
        let clLocation = makeCLLocation()
        let heading = CLHeading()
        let accuracyAuthorization: CLAccuracyAuthorization = [.fullAccuracy, .reducedAccuracy].randomElement()!

        let location = Location(
            location: clLocation,
            heading: heading,
            accuracyAuthorization: accuracyAuthorization)

        XCTAssertTrue(location.location === clLocation)
        XCTAssertTrue(location.heading === heading)
        XCTAssertEqual(location.accuracyAuthorization, accuracyAuthorization)
    }

    func testInitWithLocationNilHeadingAndAccuracyAuthorization() {
        let clLocation = makeCLLocation()
        let accuracyAuthorization: CLAccuracyAuthorization = [.fullAccuracy, .reducedAccuracy].randomElement()!

        let location = Location(
            location: clLocation,
            heading: nil,
            accuracyAuthorization: accuracyAuthorization)

        XCTAssertTrue(location.location === clLocation)
        XCTAssertNil(location.heading)
        XCTAssertEqual(location.accuracyAuthorization, accuracyAuthorization)
    }

    func testCoordinate() {
        let clLocation = makeCLLocation()

        let location = Location(
            location: clLocation,
            heading: nil,
            accuracyAuthorization: .fullAccuracy)

        XCTAssertEqual(location.coordinate, clLocation.coordinate)
    }

    func testCourse() {
        let clLocation = makeCLLocation()

        let location = Location(
            location: clLocation,
            heading: nil,
            accuracyAuthorization: .fullAccuracy)

        XCTAssertEqual(location.course, clLocation.course)
    }

    func testHorizontalAccuracy() {
        let clLocation = makeCLLocation()

        let location = Location(
            location: clLocation,
            heading: nil,
            accuracyAuthorization: .fullAccuracy)

        XCTAssertEqual(location.horizontalAccuracy, clLocation.horizontalAccuracy)
    }

    func testHeadingDirectionWhenHeadingIsNil() {
        let location = Location(
            location: makeCLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)

        XCTAssertNil(location.headingDirection)
    }

    func testHeadingDirectionWhenTrueHeadingIsValid() {
        let heading = MockHeading()
        heading.trueHeadingStub.defaultReturnValue = .random(in: 0..<360)

        let location = Location(
            location: makeCLLocation(),
            heading: heading,
            accuracyAuthorization: .fullAccuracy)

        XCTAssertEqual(location.headingDirection, heading.trueHeading)
    }

    func testHeadingDirectionWhenTrueHeadingIsInvalid() {
        let heading = MockHeading()
        heading.trueHeadingStub.defaultReturnValue = .random(in: -(.greatestFiniteMagnitude)..<0)
        heading.magneticHeadingStub.defaultReturnValue = .random(in: 0..<360)

        let location = Location(
            location: makeCLLocation(),
            heading: heading,
            accuracyAuthorization: .fullAccuracy)

        XCTAssertEqual(location.headingDirection, heading.magneticHeading)
    }
}
