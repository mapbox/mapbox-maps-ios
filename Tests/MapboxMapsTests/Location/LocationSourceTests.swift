import XCTest
@testable import MapboxMaps

final class LocationSourceTests: XCTestCase {

    var locationProvider: MockLocationProvider!
    var locationSource: LocationSource!
    // swiftlint:disable:next weak_delegate
    var delegate: MockLocationSourceDelegate!
    var consumer: MockLocationConsumer!

    override func setUp() {
        super.setUp()
        locationProvider = MockLocationProvider()
        locationSource = LocationSource(
            locationProvider: locationProvider,
            mayRequestWhenInUseAuthorization: true)
        delegate = MockLocationSourceDelegate()
        locationSource.delegate = delegate
        consumer = MockLocationConsumer()
    }

    override func tearDown() {
        consumer = nil
        delegate = nil
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

    func testRemovingConsumerAfterOtherWasDeinitedStopsUpdating() {
        autoreleasepool {
            locationSource.add(MockLocationConsumer())
        }
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
            c.locationUpdateStub.defaultSideEffect = { _ in
                XCTAssertTrue(self.locationSource.latestLocation?.location === locations[1])
            }
            locationSource.add(c)
        }

        locationSource.locationProvider(locationProvider, didUpdateLocations: locations)

        for c in consumers {
            XCTAssertEqual(c.locationUpdateStub.invocations.count, 1)
            XCTAssertTrue(c.locationUpdateStub.parameters.first?.location === locations[1])
            // accuracyAuthorization is populated with the value from the locationProvider
            // at the time of initialization. This value is only updated when the provider
            // notifies its delegate that the authorization has changed.
            XCTAssertTrue(c.locationUpdateStub.parameters.first?.accuracyAuthorization == locationProvider.accuracyAuthorization)
        }
    }

    func testConsumersAreNotifiedOfNewHeadingsAfterLatestLocationIsUpdated() {
        let heading = CLHeading()
        let location = CLLocation()
        let otherConsumer = MockLocationConsumer()
        let consumers = [consumer!, otherConsumer]

        for c in consumers {
            c.locationUpdateStub.defaultSideEffect = { _ in
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

    func testConsumersAreNotifiedOfNewAccuracyAuthorizationsAfterLatestLocationIsUpdated() {
        let location = CLLocation()
        let accuracyAuthorization = CLAccuracyAuthorization.reducedAccuracy
        let otherConsumer = MockLocationConsumer()
        let consumers = [consumer!, otherConsumer]
        locationProvider.accuracyAuthorization = accuracyAuthorization

        for c in consumers {
            c.locationUpdateStub.defaultSideEffect = { _ in
                XCTAssertTrue(self.locationSource.latestLocation?.accuracyAuthorization == accuracyAuthorization)
            }
            locationSource.add(c)
        }

        locationSource.locationProviderDidChangeAuthorization(locationProvider)
        locationSource.locationProvider(locationProvider, didUpdateLocations: [location])

        for c in consumers {
            XCTAssertEqual(c.locationUpdateStub.invocations.count, 1)
            XCTAssertTrue(c.locationUpdateStub.parameters.first?.accuracyAuthorization == accuracyAuthorization)
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

        locationSource.locationProvider = otherProvider

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
            locationSource.add(MockLocationConsumer())
        }

        locationSource.locationProvider = otherProvider

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)

        XCTAssertEqual(otherProvider.requestWhenInUseAuthorizationStub.invocations.count, 0)
        XCTAssertEqual(otherProvider.startUpdatingLocationStub.invocations.count, 0)
        XCTAssertEqual(otherProvider.startUpdatingHeadingStub.invocations.count, 0)
    }

    func testDeinit() throws {
        do {
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
    }

    func testDidUpdateLocationsUpdatesLatestLocation() {
        let location = CLLocation()

        locationSource.locationProvider(locationProvider, didUpdateLocations: [CLLocation(), location])

        XCTAssertTrue(locationSource.latestLocation?.location === location)
    }

    func testDidUpdateHeadingUpdatesLatestLocation() {
        let heading1 = CLHeading()
        let heading2 = CLHeading()
        locationSource.locationProvider(locationProvider, didUpdateHeading: heading1)

        XCTAssertNil(locationSource.latestLocation)

        locationSource.locationProvider(locationProvider, didUpdateLocations: [CLLocation()])

        XCTAssertTrue(locationSource.latestLocation?.heading === heading1)

        locationSource.locationProvider(locationProvider, didUpdateHeading: heading2)

        XCTAssertTrue(locationSource.latestLocation?.heading === heading2)
    }

    func testDidChangeAuthorizationUpdatesLatestLocation() {
        XCTAssertNil(locationSource.latestLocation)

        locationSource.locationProvider(locationProvider, didUpdateLocations: [CLLocation()])

        XCTAssertEqual(locationSource.latestLocation?.accuracyAuthorization, .fullAccuracy)

        locationProvider.accuracyAuthorization = .reducedAccuracy

        locationSource.locationProviderDidChangeAuthorization(locationProvider)

        XCTAssertEqual(locationSource.latestLocation?.accuracyAuthorization, .reducedAccuracy)
    }

    func testStopUpdatingDuringDidUpdateLocationsDueToConsumerDeinit() throws {
        locationProvider.setDelegateStub.reset()
        autoreleasepool {
            locationSource.add(MockLocationConsumer())
        }

        locationSource.locationProvider(locationProvider, didUpdateLocations: [CLLocation()])

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testStopUpdatingDuringDidUpdateHeadingDueToConsumerDeinit() {
        locationProvider.setDelegateStub.reset()
        autoreleasepool {
            locationSource.add(MockLocationConsumer())
        }

        locationSource.locationProvider(locationProvider, didUpdateHeading: CLHeading())

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testStopUpdatingDuringDidFailWithErrorDueToConsumerDeinit() {
        locationProvider.setDelegateStub.reset()
        autoreleasepool {
            locationSource.add(MockLocationConsumer())
        }

        locationSource.locationProvider(locationProvider, didFailWithError: MockError())

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
        XCTAssertEqual(delegate?.didFailWithErrorStub.invocations.count, 1)
    }

    func testStopUpdatingDuringDidChangeAuthorizationDueToConsumerDeinit() {
        locationProvider.setDelegateStub.reset()
        autoreleasepool {
            locationSource.add(MockLocationConsumer())
        }

        locationProvider.accuracyAuthorization = .reducedAccuracy
        locationSource.locationProviderDidChangeAuthorization(locationProvider)

        XCTAssertEqual(locationProvider.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationProvider.stopUpdatingHeadingStub.invocations.count, 1)
        XCTAssertEqual(delegate?.didChangeAccuracyAuthorizationStub.invocations.count, 1)
    }

    func testDidFailWithErrorNotifiesDelegate() throws {
        locationSource.add(consumer)
        let error = MockError()

        locationSource.locationProvider(locationProvider, didFailWithError: error)

        XCTAssertEqual(delegate.didFailWithErrorStub.invocations.count, 1)
        XCTAssertTrue(delegate.didFailWithErrorStub.parameters.first?.locationSource === locationSource)
        let actualError = try XCTUnwrap(delegate.didFailWithErrorStub.parameters.first?.error)
        XCTAssertTrue((actualError as? MockError) === error)
    }

    func testDidChangeAuthorizationNotifiesDelegateIfAccuracyAuthorizationChanged() {
        let accuracyAuthorizationValues: [CLAccuracyAuthorization] = [.fullAccuracy, .reducedAccuracy]
        let initialIndex = Int.random(in: 0...1)
        let changedIndex = (initialIndex + 1) % 2 // the other one
        locationProvider.accuracyAuthorization = accuracyAuthorizationValues[initialIndex]
        locationSource = LocationSource(
            locationProvider: locationProvider,
            mayRequestWhenInUseAuthorization: true)
        delegate = MockLocationSourceDelegate()
        locationSource.delegate = delegate
        locationSource.add(consumer)
        locationProvider.accuracyAuthorization = accuracyAuthorizationValues[changedIndex]

        locationSource.locationProviderDidChangeAuthorization(locationProvider)

        XCTAssertEqual(delegate.didChangeAccuracyAuthorizationStub.invocations.count, 1)
        XCTAssertTrue(delegate.didChangeAccuracyAuthorizationStub.parameters.first?.locationSource === locationSource)
        XCTAssertEqual(delegate.didChangeAccuracyAuthorizationStub.parameters.first?.accuracyAuthorization, locationProvider.accuracyAuthorization)
    }

    func testDidChangeAuthorizationDoesNotNotifyDelegateIfAccuracyAuthorizationDidNotChange() {
        locationProvider.accuracyAuthorization = [.fullAccuracy, .reducedAccuracy].randomElement()!
        locationSource = LocationSource(
            locationProvider: locationProvider,
            mayRequestWhenInUseAuthorization: true)
        delegate = MockLocationSourceDelegate()
        locationSource.delegate = delegate
        locationSource.add(consumer)

        locationSource.locationProviderDidChangeAuthorization(locationProvider)

        XCTAssertEqual(delegate.didChangeAccuracyAuthorizationStub.invocations.count, 0)
    }

    func testRequestsTemporaryFullAccuracyAuthorizationWhenAccuracyIsReduced() {
        locationSource.add(consumer)
        locationProvider.authorizationStatus = [.authorizedAlways, .authorizedWhenInUse].randomElement()!
        locationProvider.accuracyAuthorization = .reducedAccuracy

        locationSource.locationProviderDidChangeAuthorization(locationProvider)

        if #available(iOS 14.0, *) {
            XCTAssertEqual(
                locationProvider.requestTemporaryFullAccuracyAuthorizationStub.parameters,
                ["LocationAccuracyAuthorizationDescription"])
        } else {
            XCTAssertTrue(locationProvider.requestTemporaryFullAccuracyAuthorizationStub.invocations.isEmpty)
        }
    }

    func testDoesNotRequestTemporaryFullAccuracyAuthorizationIfPermissionsNotGranted() {
        locationSource.add(consumer)
        locationProvider.authorizationStatus = [.notDetermined, .restricted, .denied].randomElement()!
        locationProvider.accuracyAuthorization = .reducedAccuracy

        locationSource.locationProviderDidChangeAuthorization(locationProvider)

        XCTAssertTrue(locationProvider.requestTemporaryFullAccuracyAuthorizationStub.invocations.isEmpty)
    }

    func testDoesNotRequestTemporaryFullAccuracyAuthorizationWhenAccuracyIsFull() {
        locationSource.add(consumer)
        locationProvider.authorizationStatus = [.authorizedAlways, .authorizedWhenInUse].randomElement()!
        locationProvider.accuracyAuthorization = .fullAccuracy

        locationSource.locationProviderDidChangeAuthorization(locationProvider)

        XCTAssertTrue(locationProvider.requestTemporaryFullAccuracyAuthorizationStub.invocations.isEmpty)
    }

    func testDoesNotRequestTemporaryFullAccuracyAuthorizationWhenNotUpdating() {
        locationProvider.authorizationStatus = [.authorizedAlways, .authorizedWhenInUse].randomElement()!
        locationProvider.accuracyAuthorization = .reducedAccuracy

        locationSource.locationProviderDidChangeAuthorization(locationProvider)

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

        XCTAssertEqual(locationSource.headingOrientation, locationProvider.headingOrientation)

        locationSource.headingOrientation = [
            .portrait,
            .portraitUpsideDown,
            .faceUp,
            .faceDown,
            .landscapeLeft,
            .landscapeRight,
            .unknown].randomElement()!

        XCTAssertEqual(locationProvider.headingOrientation, locationSource.headingOrientation)
    }
}
