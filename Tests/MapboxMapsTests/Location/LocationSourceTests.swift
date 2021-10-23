import XCTest
@testable import MapboxMaps

final class LocationSourceTests: XCTestCase {

    var locationProvider: MockLocationProvider!
    var locationSource: LocationSource!
    var consumer: MockLocationConsumer!

    override func setUp() {
        super.setUp()
        locationProvider = MockLocationProvider()
        locationSource = LocationSource(
            locationProvider: locationProvider,
            mayRequestWhenInUseAuthorization: true)
        consumer = MockLocationConsumer()
    }

    override func tearDown() {
        consumer = nil
        locationSource = nil
        locationProvider = nil
        super.tearDown()
    }

    func testInitializationDoesNotStartOrStopUpdating() {
        XCTAssertTrue(locationProvider.startUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.startUpdatingHeadingStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.stopUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.stopUpdatingHeadingStub.invocations.isEmpty)
    }

    func testAddingConsumerStartsUpdating() {
        locationSource.add(consumer)

        XCTAssertEqual(locationProvider.startUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.startUpdatingHeadingStub.invocations.count, 1)
        XCTAssertTrue(locationProvider.stopUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.stopUpdatingHeadingStub.invocations.isEmpty)
    }

    func testRemovingAllConsumerStopsUpdating() {
        locationSource.add(consumer)
        locationSource.remove(consumer)

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testAddingAConsumerMoreThanOnceHasNoEffect() {
        locationSource.add(consumer)
        locationSource.add(consumer)
        locationSource.remove(consumer)

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testRemovingAConsumerMoreThanOnceHasNoEffect() {
        locationSource.add(consumer)
        locationSource.remove(consumer)
        locationProvider.stopUpdatingLocationStub.reset()
        locationProvider.stopUpdatingHeadingStub.reset()

        locationSource.remove(consumer)

        XCTAssertTrue(locationProvider.stopUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.stopUpdatingHeadingStub.invocations.isEmpty)
    }

    func testAddingAConsumerRequestsWhenInUseAuthorizationIfStatusIsNotDetermined() {
        locationProvider.authorizationStatus = .notDetermined

        locationSource.add(consumer)

        XCTAssertEqual(locationProvider.requestWhenInUseAuthorizationStub.invocations.count, 1)
    }

    func testAddingAConsumerDoesNotRequestWhenInUseAuthorizationForOtherStatuses() {
        locationProvider.authorizationStatus = [.restricted, .denied, .authorizedAlways, .authorizedWhenInUse].randomElement()!

        locationSource.add(consumer)

        XCTAssertTrue(locationProvider.requestWhenInUseAuthorizationStub.invocations.isEmpty)
    }

    func testAddingAConsumerDoesNotRequestWhenInUseAuthorizationIfDisallowed() {
        locationSource = LocationSource(
            locationProvider: locationProvider,
            mayRequestWhenInUseAuthorization: false)
        locationProvider.authorizationStatus = .notDetermined

        locationSource.add(consumer)

        XCTAssertTrue(locationProvider.requestWhenInUseAuthorizationStub.invocations.isEmpty)
    }

    func testConsumersAreNotifiedOfNewLocationsAfterLatestLocationIsUpdated() {
        let locations = [
            CLLocation(latitude: 0, longitude: 0),
            CLLocation(latitude: 1, longitude: 1)]
        let otherConsumer = MockLocationConsumer()
        let consumers = [consumer!, otherConsumer]

        for c in consumers {
            c.locationUpdateStub.defaultSideEffect = { invocation in
                XCTAssertTrue(self.locationSource.latestLocation?.location === locations[1])
            }
            locationSource.add(c)
        }

        locationSource.locationProvider(locationProvider, didUpdateLocations: locations)

        for c in consumers {
            XCTAssertEqual(c.locationUpdateStub.invocations.count, 1)
            XCTAssertTrue(c.locationUpdateStub.parameters.first?.location === locations[1])
        }
    }

    func testConsumersAreNotifiedOfNewHeadingsAfterLatestLocationIsUpdated() {
        let heading = CLHeading()
        let location = CLLocation()
        let otherConsumer = MockLocationConsumer()
        let consumers = [consumer!, otherConsumer]

        for c in consumers {
            c.locationUpdateStub.defaultSideEffect = { invocation in
                XCTAssertTrue(self.locationSource.latestLocation?.heading === heading)
            }
            locationSource.add(c)
        }

        locationSource.locationProvider(locationProvider, didUpdateHeading: heading)
        locationSource.locationProvider(locationProvider, didUpdateLocations: [location])

        for c in consumers {
            XCTAssertEqual(c.locationUpdateStub.invocations.count, 1)
            XCTAssertTrue(c.locationUpdateStub.parameters.first?.heading === heading)
        }
    }

    func testConsumersReturnsACopy() {
        locationSource.add(consumer)

        let consumers = locationSource.consumers

        XCTAssertTrue(consumers.contains(consumer))

        locationSource.remove(consumer)

        let consumers2 = locationSource.consumers

        XCTAssertTrue(consumers.contains(consumer))
        XCTAssertFalse(consumers2.contains(consumer))

        locationSource.add(consumer)

        // this just removes from the returned copy
        locationSource.consumers.remove(consumer)

        XCTAssertTrue(locationSource.consumers.contains(consumer))
    }

    func testSetLocationProviderWithNoConsumers() throws {
        let otherProvider = MockLocationProvider()
        locationProvider.setDelegateStub.reset()

        locationSource.locationProvider = otherProvider

        XCTAssertEqual(locationProvider.setDelegateStub.invocations.count, 1)
        let delegate = try XCTUnwrap(locationProvider.setDelegateStub.parameters.first)
        XCTAssertTrue(delegate is EmptyLocationProviderDelegate)

        XCTAssertEqual(otherProvider.setDelegateStub.invocations.count, 1)
        XCTAssertTrue(otherProvider.setDelegateStub.parameters.first === locationSource)

        XCTAssertTrue(locationProvider.startUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.startUpdatingHeadingStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.stopUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.stopUpdatingHeadingStub.invocations.isEmpty)
    }

    func testSetLocationProviderWithConsumers() {
        let otherProvider = MockLocationProvider()
        otherProvider.authorizationStatus = .notDetermined
        locationSource.add(consumer)
        locationProvider.setDelegateStub.reset()
        locationProvider.startUpdatingLocationStub.reset()
        locationProvider.startUpdatingHeadingStub.reset()

        locationSource.locationProvider = otherProvider

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)

        XCTAssertEqual(otherProvider.requestWhenInUseAuthorizationStub.invocations.count, 1)
        XCTAssertEqual(otherProvider.startUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(otherProvider.startUpdatingHeadingStub.invocations.count, 1)
    }

    func testDeinit() throws {
        autoreleasepool {
            let locationSource = LocationSource(
                locationProvider: locationProvider,
                mayRequestWhenInUseAuthorization: true)
            locationSource.add(consumer)
            // reset to break a strong reference cycle from
            // locationSource -> locationProvider -> setDelegateStub
            // -> locationSource
            locationProvider.setDelegateStub.reset()
        }
        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.setDelegateStub.invocations.count, 1)
        let delegate = try XCTUnwrap(locationProvider.setDelegateStub.parameters.first)
        XCTAssertTrue(delegate is EmptyLocationProviderDelegate)
    }

    func testHeadingOrientationManagement() {
        // test that it's updated when the heading changes (is this even right?
        // shouldn't it be in response to device orientation changes???)
    }

    func testStopUpdatingDuringDidUpdateLocationsDueToConsumerDeinit() throws {
        locationProvider.setDelegateStub.reset()

        autoreleasepool {
            let consumer = MockLocationConsumer()
            locationSource.add(consumer)
        }
        locationSource.locationProvider(locationProvider, didUpdateLocations: [CLLocation()])

        XCTAssertNil(locationSource.latestLocation)
        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testStopUpdatingDuringDidUpdateHeadingDueToConsumerDeinit() {
        locationProvider.setDelegateStub.reset()

        autoreleasepool {
            let consumer = MockLocationConsumer()
            locationSource.add(consumer)
            locationSource.locationProvider(locationProvider, didUpdateLocations: [CLLocation()])
        }
        locationSource.locationProvider(locationProvider, didUpdateHeading: CLHeading())

        XCTAssertNil(locationSource.latestLocation?.heading)
        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testStopUpdatingDuringDidFailWithErrorDueToConsumerDeinit() {
    }

    func testStopUpdatingDuringDidChangeAuthorizationDueToConsumerDeinit() {
    }

    func testLocationSourceDelegateDidChangeAuthorization() {
        // TODO: finish removing old implementation in LocationManager
        // and only expose the minimum necessary delegate API for
        // LocationSource
    }

    func testRequestsTemporaryFullAccuracyAuthorization() {
    }
}
