import XCTest
@testable import MapboxMaps

final class LocationProducerTests: XCTestCase {

    var locationProvider: MockLocationProvider!
    var locationProducer: LocationProducer!
    // swiftlint:disable:next weak_delegate
    var delegate: MockLocationProducerDelegate!
    var consumer: MockLocationConsumer!

    override func setUp() {
        super.setUp()
        locationProvider = MockLocationProvider()
        locationProducer = LocationProducer(
            locationProvider: locationProvider,
            mayRequestWhenInUseAuthorization: true)
        delegate = MockLocationProducerDelegate()
        locationProducer.delegate = delegate
        consumer = MockLocationConsumer()
    }

    override func tearDown() {
        consumer = nil
        delegate = nil
        locationProducer = nil
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
        locationProducer.add(consumer)

        XCTAssertEqual(locationProvider.startUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.startUpdatingHeadingStub.invocations.count, 1)
        XCTAssertTrue(locationProvider.stopUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.stopUpdatingHeadingStub.invocations.isEmpty)
    }

    func testRemovingAllConsumerStopsUpdating() {
        locationProducer.add(consumer)
        locationProducer.remove(consumer)

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testRemovingConsumerAfterOtherWasDeinitedStopsUpdating() {
        autoreleasepool {
            locationProducer.add(MockLocationConsumer())
        }
        locationProducer.add(consumer)
        locationProducer.remove(consumer)

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testAddingAConsumerMoreThanOnceHasNoEffect() {
        locationProducer.add(consumer)
        locationProducer.add(consumer)
        locationProducer.remove(consumer)

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testRemovingAConsumerMoreThanOnceHasNoEffect() {
        locationProducer.add(consumer)
        locationProducer.remove(consumer)
        locationProvider.stopUpdatingLocationStub.reset()
        locationProvider.stopUpdatingHeadingStub.reset()

        locationProducer.remove(consumer)

        XCTAssertTrue(locationProvider.stopUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.stopUpdatingHeadingStub.invocations.isEmpty)
    }

    func testAddingAConsumerRequestsWhenInUseAuthorizationIfStatusIsNotDetermined() {
        locationProvider.authorizationStatus = .notDetermined

        locationProducer.add(consumer)

        XCTAssertEqual(locationProvider.requestWhenInUseAuthorizationStub.invocations.count, 1)
    }

    func testAddingAConsumerDoesNotRequestWhenInUseAuthorizationForOtherStatuses() {
        locationProvider.authorizationStatus = [.restricted, .denied, .authorizedAlways, .authorizedWhenInUse].randomElement()!

        locationProducer.add(consumer)

        XCTAssertTrue(locationProvider.requestWhenInUseAuthorizationStub.invocations.isEmpty)
    }

    func testAddingAConsumerDoesNotRequestWhenInUseAuthorizationIfDisallowed() {
        locationProducer = LocationProducer(
            locationProvider: locationProvider,
            mayRequestWhenInUseAuthorization: false)
        locationProvider.authorizationStatus = .notDetermined

        locationProducer.add(consumer)

        XCTAssertTrue(locationProvider.requestWhenInUseAuthorizationStub.invocations.isEmpty)
    }

    func testConsumersAreNotifiedOfNewLocationsAfterLatestLocationIsUpdated() {
        let locations = [
            CLLocation(latitude: 0, longitude: 0),
            CLLocation(latitude: 1, longitude: 1)]
        let otherConsumer = MockLocationConsumer()
        let consumers = [consumer!, otherConsumer]

        for c in consumers {
            c.locationUpdateStub.defaultSideEffect = { _ in
                XCTAssertTrue(self.locationProducer.latestLocation?.location === locations[1])
            }
            locationProducer.add(c)
        }

        locationProducer.locationProvider(locationProvider, didUpdateLocations: locations)

        for c in consumers {
            XCTAssertEqual(c.locationUpdateStub.invocations.count, 1)
            XCTAssertTrue(c.locationUpdateStub.invocations.first?.parameters.location === locations[1])
            // accuracyAuthorization is populated with the value from the locationProvider
            // at the time of initialization. This value is only updated when the provider
            // notifies its delegate that the authorization has changed.
            XCTAssertTrue(c.locationUpdateStub.invocations.first?.parameters.accuracyAuthorization == locationProvider.accuracyAuthorization)
        }
    }

    func testConsumersAreNotifiedOfNewHeadingsAfterLatestLocationIsUpdated() {
        let heading = CLHeading()
        let location = CLLocation()
        let otherConsumer = MockLocationConsumer()
        let consumers = [consumer!, otherConsumer]

        for c in consumers {
            c.locationUpdateStub.defaultSideEffect = { _ in
                XCTAssertTrue(self.locationProducer.latestLocation?.heading === heading)
            }
            locationProducer.add(c)
        }

        locationProducer.locationProvider(locationProvider, didUpdateHeading: heading)
        locationProducer.locationProvider(locationProvider, didUpdateLocations: [location])

        for c in consumers {
            XCTAssertEqual(c.locationUpdateStub.invocations.count, 1)
            XCTAssertTrue(c.locationUpdateStub.invocations.first?.parameters.heading === heading)
        }
    }

    func testConsumersAreNotifiedOfNewAccuracyAuthorizationsAfterLatestLocationIsUpdated() {
        let location = CLLocation()
        let accuracyAuthorization = CLAccuracyAuthorization.reducedAccuracy
        let otherConsumer = MockLocationConsumer()
        let consumers = [consumer!, otherConsumer]
        locationProvider.accuracyAuthorization = accuracyAuthorization

        for c in consumers {
            c.locationUpdateStub.defaultSideEffect = { _ in
                XCTAssertTrue(self.locationProducer.latestLocation?.accuracyAuthorization == accuracyAuthorization)
            }
            locationProducer.add(c)
        }

        locationProducer.locationProviderDidChangeAuthorization(locationProvider)
        locationProducer.locationProvider(locationProvider, didUpdateLocations: [location])

        for c in consumers {
            XCTAssertEqual(c.locationUpdateStub.invocations.count, 1)
            XCTAssertTrue(c.locationUpdateStub.invocations.first?.parameters.accuracyAuthorization == accuracyAuthorization)
        }
    }

    func testConsumersReturnsACopy() {
        locationProducer.add(consumer)

        let consumers = locationProducer.consumers

        XCTAssertTrue(consumers.contains(consumer))

        locationProducer.remove(consumer)

        let consumers2 = locationProducer.consumers

        XCTAssertTrue(consumers.contains(consumer))
        XCTAssertFalse(consumers2.contains(consumer))

        locationProducer.add(consumer)

        // this just removes from the returned copy
        locationProducer.consumers.remove(consumer)

        XCTAssertTrue(locationProducer.consumers.contains(consumer))
    }

    func testSetLocationProviderWithNoConsumers() throws {
        let otherProvider = MockLocationProvider()
        locationProvider.setDelegateStub.reset()

        locationProducer.locationProvider = otherProvider

        XCTAssertEqual(locationProvider.setDelegateStub.invocations.count, 1)
        let delegate = try XCTUnwrap(locationProvider.setDelegateStub.invocations.first?.parameters)
        XCTAssertTrue(delegate is EmptyLocationProviderDelegate)

        XCTAssertEqual(otherProvider.setDelegateStub.invocations.count, 1)
        XCTAssertTrue(otherProvider.setDelegateStub.invocations.first?.parameters === locationProducer)

        XCTAssertTrue(locationProvider.startUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.startUpdatingHeadingStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.stopUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.stopUpdatingHeadingStub.invocations.isEmpty)
    }

    func testSetLocationProviderWithConsumers() {
        let otherProvider = MockLocationProvider()
        otherProvider.authorizationStatus = .notDetermined
        locationProducer.add(consumer)

        locationProducer.locationProvider = otherProvider

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)

        XCTAssertEqual(otherProvider.requestWhenInUseAuthorizationStub.invocations.count, 1)
        XCTAssertEqual(otherProvider.startUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(otherProvider.startUpdatingHeadingStub.invocations.count, 1)
    }

    func testSetLocationProviderWithRecentlyDeinitedConsumers() {
        let otherProvider = MockLocationProvider()
        otherProvider.authorizationStatus = .notDetermined
        locationProvider.setDelegateStub.reset()
        // Add a consumer that will be immediately deinited.
        // This causes location updates to be started on the
        // old location provider, but they should not be
        // started on the new one.
        autoreleasepool {
            locationProducer.add(MockLocationConsumer())
        }

        locationProducer.locationProvider = otherProvider

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)

        XCTAssertEqual(otherProvider.requestWhenInUseAuthorizationStub.invocations.count, 0)
        XCTAssertEqual(otherProvider.startUpdatingLocationStub.invocations.count, 0)
        XCTAssertEqual(otherProvider.startUpdatingHeadingStub.invocations.count, 0)
    }

    func testDeinit() throws {
        do {
            let locationProducer = LocationProducer(
                locationProvider: locationProvider,
                mayRequestWhenInUseAuthorization: true)
            locationProducer.add(consumer)
            // reset to break a strong reference cycle from
            // locationProducer -> locationProvider -> setDelegateStub
            // -> locationProducer
            locationProvider.setDelegateStub.reset()
        }
        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testDidUpdateLocationsUpdatesLatestLocation() {
        let location = CLLocation()

        locationProducer.locationProvider(locationProvider, didUpdateLocations: [CLLocation(), location])

        XCTAssertTrue(locationProducer.latestLocation?.location === location)
    }

    func testDidUpdateHeadingUpdatesLatestLocation() {
        let heading1 = CLHeading()
        let heading2 = CLHeading()
        locationProducer.locationProvider(locationProvider, didUpdateHeading: heading1)

        XCTAssertNil(locationProducer.latestLocation)

        locationProducer.locationProvider(locationProvider, didUpdateLocations: [CLLocation()])

        XCTAssertTrue(locationProducer.latestLocation?.heading === heading1)

        locationProducer.locationProvider(locationProvider, didUpdateHeading: heading2)

        XCTAssertTrue(locationProducer.latestLocation?.heading === heading2)
    }

    func testDidChangeAuthorizationUpdatesLatestLocation() {
        XCTAssertNil(locationProducer.latestLocation)

        locationProducer.locationProvider(locationProvider, didUpdateLocations: [CLLocation()])

        XCTAssertEqual(locationProducer.latestLocation?.accuracyAuthorization, .fullAccuracy)

        locationProvider.accuracyAuthorization = .reducedAccuracy

        locationProducer.locationProviderDidChangeAuthorization(locationProvider)

        XCTAssertEqual(locationProducer.latestLocation?.accuracyAuthorization, .reducedAccuracy)
    }

    func testStopUpdatingDuringDidUpdateLocationsDueToConsumerDeinit() throws {
        locationProvider.setDelegateStub.reset()
        autoreleasepool {
            locationProducer.add(MockLocationConsumer())
        }

        locationProducer.locationProvider(locationProvider, didUpdateLocations: [CLLocation()])

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testStopUpdatingDuringDidUpdateHeadingDueToConsumerDeinit() {
        locationProvider.setDelegateStub.reset()
        autoreleasepool {
            locationProducer.add(MockLocationConsumer())
        }

        locationProducer.locationProvider(locationProvider, didUpdateHeading: CLHeading())

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testStopUpdatingDuringDidFailWithErrorDueToConsumerDeinit() {
        locationProvider.setDelegateStub.reset()
        autoreleasepool {
            locationProducer.add(MockLocationConsumer())
        }

        locationProducer.locationProvider(locationProvider, didFailWithError: MockError())

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
        XCTAssertEqual(delegate?.didFailWithErrorStub.invocations.count, 1)
    }

    func testStopUpdatingDuringDidChangeAuthorizationDueToConsumerDeinit() {
        locationProvider.setDelegateStub.reset()
        autoreleasepool {
            locationProducer.add(MockLocationConsumer())
        }

        locationProvider.accuracyAuthorization = .reducedAccuracy
        locationProducer.locationProviderDidChangeAuthorization(locationProvider)

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
        XCTAssertEqual(delegate?.didChangeAccuracyAuthorizationStub.invocations.count, 1)
    }

    func testDidFailWithErrorNotifiesDelegate() throws {
        locationProducer.add(consumer)
        let error = MockError()

        locationProducer.locationProvider(locationProvider, didFailWithError: error)

        XCTAssertEqual(delegate.didFailWithErrorStub.invocations.count, 1)
        XCTAssertTrue(delegate.didFailWithErrorStub.invocations.first?.parameters.locationProducer === locationProducer)
        let actualError = try XCTUnwrap(delegate.didFailWithErrorStub.invocations.first?.parameters.error)
        XCTAssertTrue((actualError as? MockError) === error)
    }

    func testDidChangeAuthorizationNotifiesDelegateIfAccuracyAuthorizationChanged() {
        let accuracyAuthorizationValues: [CLAccuracyAuthorization] = [.fullAccuracy, .reducedAccuracy]
        let initialIndex = Int.random(in: 0...1)
        let changedIndex = (initialIndex + 1) % 2 // the other one
        locationProvider.accuracyAuthorization = accuracyAuthorizationValues[initialIndex]
        locationProducer = LocationProducer(
            locationProvider: locationProvider,
            mayRequestWhenInUseAuthorization: true)
        delegate = MockLocationProducerDelegate()
        locationProducer.delegate = delegate
        locationProducer.add(consumer)
        locationProvider.accuracyAuthorization = accuracyAuthorizationValues[changedIndex]

        locationProducer.locationProviderDidChangeAuthorization(locationProvider)

        XCTAssertEqual(delegate.didChangeAccuracyAuthorizationStub.invocations.count, 1)
        XCTAssertTrue(delegate.didChangeAccuracyAuthorizationStub.invocations.first?.parameters.locationProducer === locationProducer)
        XCTAssertEqual(delegate.didChangeAccuracyAuthorizationStub.invocations.first?.parameters.accuracyAuthorization, locationProvider.accuracyAuthorization)
    }

    func testDidChangeAuthorizationDoesNotNotifyDelegateIfAccuracyAuthorizationDidNotChange() {
        locationProvider.accuracyAuthorization = [.fullAccuracy, .reducedAccuracy].randomElement()!
        locationProducer = LocationProducer(
            locationProvider: locationProvider,
            mayRequestWhenInUseAuthorization: true)
        delegate = MockLocationProducerDelegate()
        locationProducer.delegate = delegate
        locationProducer.add(consumer)

        locationProducer.locationProviderDidChangeAuthorization(locationProvider)

        XCTAssertEqual(delegate.didChangeAccuracyAuthorizationStub.invocations.count, 0)
    }

    func testRequestsTemporaryFullAccuracyAuthorizationWhenAccuracyIsReduced() {
        locationProducer.add(consumer)
        locationProvider.authorizationStatus = [.authorizedAlways, .authorizedWhenInUse].randomElement()!
        locationProvider.accuracyAuthorization = .reducedAccuracy

        locationProducer.locationProviderDidChangeAuthorization(locationProvider)

        if #available(iOS 14.0, *) {
            XCTAssertEqual(
                locationProvider.requestTemporaryFullAccuracyAuthorizationStub.invocations.map(\.parameters),
                ["LocationAccuracyAuthorizationDescription"])
        } else {
            XCTAssertTrue(locationProvider.requestTemporaryFullAccuracyAuthorizationStub.invocations.isEmpty)
        }
    }

    func testDoesNotRequestTemporaryFullAccuracyAuthorizationIfPermissionsNotGranted() {
        locationProducer.add(consumer)
        locationProvider.authorizationStatus = [.notDetermined, .restricted, .denied].randomElement()!
        locationProvider.accuracyAuthorization = .reducedAccuracy

        locationProducer.locationProviderDidChangeAuthorization(locationProvider)

        XCTAssertTrue(locationProvider.requestTemporaryFullAccuracyAuthorizationStub.invocations.isEmpty)
    }

    func testDoesNotRequestTemporaryFullAccuracyAuthorizationWhenAccuracyIsFull() {
        locationProducer.add(consumer)
        locationProvider.authorizationStatus = [.authorizedAlways, .authorizedWhenInUse].randomElement()!
        locationProvider.accuracyAuthorization = .fullAccuracy

        locationProducer.locationProviderDidChangeAuthorization(locationProvider)

        XCTAssertTrue(locationProvider.requestTemporaryFullAccuracyAuthorizationStub.invocations.isEmpty)
    }

    func testDoesNotRequestTemporaryFullAccuracyAuthorizationWhenNotUpdating() {
        locationProvider.authorizationStatus = [.authorizedAlways, .authorizedWhenInUse].randomElement()!
        locationProvider.accuracyAuthorization = .reducedAccuracy

        locationProducer.locationProviderDidChangeAuthorization(locationProvider)

        XCTAssertTrue(locationProvider.requestTemporaryFullAccuracyAuthorizationStub.invocations.isEmpty)
    }

    func testHeadingOrientation() {
        locationProvider.headingOrientation = [
            .portrait,
            .portraitUpsideDown,
            .faceUp,
            .faceDown,
            .landscapeLeft,
            .landscapeRight,
            .unknown].randomElement()!

        XCTAssertEqual(locationProducer.headingOrientation, locationProvider.headingOrientation)

        locationProducer.headingOrientation = [
            .portrait,
            .portraitUpsideDown,
            .faceUp,
            .faceDown,
            .landscapeLeft,
            .landscapeRight,
            .unknown].randomElement()!

        XCTAssertEqual(locationProvider.headingOrientation, locationProducer.headingOrientation)
    }
}
