import XCTest
@testable import MapboxMaps
import UIKit

final class AppleLocationProviderTests: XCTestCase {

    var locationManager: MockCLLocationManager!
    var locationProvider: AppleLocationProvider!
    // swiftlint:disable:next weak_delegate
    var delegate: MockLocationProducerDelegate!
    var consumer: MockLocationConsumer!
    var interfaceOrientationProvider: MockInterfaceOrientationProvider!
    var locationManagerDelegateProxy: CLLocationManagerDelegateProxy!

    override func setUp() {
        super.setUp()
        locationManager = MockCLLocationManager()
        interfaceOrientationProvider = MockInterfaceOrientationProvider()
        locationManagerDelegateProxy = CLLocationManagerDelegateProxy()
        locationProvider = AppleLocationProvider(
            locationManager: locationManager,
            interfaceOrientationProvider: interfaceOrientationProvider,
            mayRequestWhenInUseAuthorization: true,
            locationManagerDelegateProxy: locationManagerDelegateProxy)
        delegate = MockLocationProducerDelegate()
        locationProvider.delegate = delegate
        consumer = MockLocationConsumer()
    }

    override func tearDown() {
        interfaceOrientationProvider = nil
        consumer = nil
        delegate = nil
        locationProvider = nil
        locationManagerDelegateProxy = nil
        locationManager = nil
        super.tearDown()
    }

    func testInitializationDoesNotStartOrStopUpdating() {
        XCTAssertTrue(locationManager.startUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationManager.startUpdatingHeadingStub.invocations.isEmpty)
        XCTAssertTrue(locationManager.stopUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationManager.stopUpdatingHeadingStub.invocations.isEmpty)
    }

    func testAddingConsumerStartsUpdating() {
        locationProvider.add(consumer: consumer)

        XCTAssertEqual(locationManager.startUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationManager.startUpdatingHeadingStub.invocations.count, 1)
        XCTAssertTrue(locationManager.stopUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationManager.stopUpdatingHeadingStub.invocations.isEmpty)
    }

    func testRemovingAllConsumerStopsUpdating() {
        locationProvider.add(consumer: consumer)
        locationProvider.remove(consumer: consumer)

        XCTAssertEqual(locationManager.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationManager.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testRemovingConsumerAfterOtherWasDeinitedStopsUpdating() {
        autoreleasepool {
            locationProvider.add(consumer: MockLocationConsumer())
        }
        locationProvider.add(consumer: consumer)
        locationProvider.remove(consumer: consumer)

        XCTAssertEqual(locationManager.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationManager.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testAddingAConsumerMoreThanOnceHasNoEffect() {
        locationProvider.add(consumer: consumer)
        locationProvider.add(consumer: consumer)
        locationProvider.remove(consumer: consumer)

        XCTAssertEqual(locationManager.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationManager.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testRemovingAConsumerMoreThanOnceHasNoEffect() {
        locationProvider.add(consumer: consumer)
        locationProvider.remove(consumer: consumer)
        locationManager.stopUpdatingLocationStub.reset()
        locationManager.stopUpdatingHeadingStub.reset()

        locationProvider.remove(consumer: consumer)

        XCTAssertTrue(locationManager.stopUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationManager.stopUpdatingHeadingStub.invocations.isEmpty)
    }

    func testAddingAConsumerRequestsWhenInUseAuthorizationIfStatusIsNotDetermined() {
        locationManager.compatibleAuthorizationStatus = .notDetermined

        locationProvider.add(consumer: consumer)

        XCTAssertEqual(locationManager.requestWhenInUseAuthorizationStub.invocations.count, 1)
    }

    func testAddingAConsumerDoesNotRequestWhenInUseAuthorizationForOtherStatuses() {
        locationManager.compatibleAuthorizationStatus = [.restricted, .denied, .authorizedAlways, .authorizedWhenInUse].randomElement()!

        locationProvider.add(consumer: consumer)

        XCTAssertTrue(locationManager.requestWhenInUseAuthorizationStub.invocations.isEmpty)
    }

    func testAddingAConsumerDoesNotRequestWhenInUseAuthorizationIfDisallowed() {
        locationProvider = AppleLocationProvider(
            locationManager: locationManager,
            interfaceOrientationProvider: interfaceOrientationProvider,
            mayRequestWhenInUseAuthorization: false,
            locationManagerDelegateProxy: locationManagerDelegateProxy)
        locationManager.compatibleAuthorizationStatus = .notDetermined

        locationProvider.add(consumer: consumer)

        XCTAssertTrue(locationManager.requestWhenInUseAuthorizationStub.invocations.isEmpty)
    }

    func testConsumersAreNotifiedOfNewLocationsAfterLatestLocationIsUpdated() {
        let locations = [
            CLLocation(latitude: 0, longitude: 0),
            CLLocation(latitude: 1, longitude: 1)]
        let otherConsumer = MockLocationConsumer()
        let consumers = [consumer!, otherConsumer]

        for c in consumers {
            c.locationUpdateStub.defaultSideEffect = { _ in
                XCTAssertTrue(self.locationProvider.latestLocation?.location === locations[1])
            }
            locationProvider.add(consumer: c)
        }

        locationProvider.locationManager(CLLocationManager(), didUpdateLocations: locations)

        for c in consumers {
            XCTAssertEqual(c.locationUpdateStub.invocations.count, 1)
            XCTAssertTrue(c.locationUpdateStub.invocations.first?.parameters.location === locations[1])
            // accuracyAuthorization is populated with the value from the locationProvider
            // at the time of initialization. This value is only updated when the provider
            // notifies its delegate that the authorization has changed.
            XCTAssertTrue(c.locationUpdateStub.invocations.first?.parameters.accuracyAuthorization == locationManager.compatibleAccuracyAuthorization)
        }
    }

    func testConsumersAreNotifiedOfNewHeadingsAfterLatestLocationIsUpdated() {
        let heading = CLHeading()
        let location = CLLocation()
        let otherConsumer = MockLocationConsumer()
        let consumers = [consumer!, otherConsumer]

        for c in consumers {
            c.locationUpdateStub.defaultSideEffect = { _ in
                XCTAssertTrue(self.locationProvider.latestLocation?.heading === heading)
            }
            locationProvider.add(consumer: c)
        }

        locationProvider.locationManager(CLLocationManager(), didUpdateHeading: heading)
        locationProvider.locationManager(CLLocationManager(), didUpdateLocations: [location])

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
        locationManager.compatibleAccuracyAuthorization = accuracyAuthorization

        for c in consumers {
            c.locationUpdateStub.defaultSideEffect = { _ in
                XCTAssertTrue(self.locationProvider.latestLocation?.accuracyAuthorization == accuracyAuthorization)
            }
            locationProvider.add(consumer: c)
        }

        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())
        locationProvider.locationManager(CLLocationManager(), didUpdateLocations: [location])

        for c in consumers {
            XCTAssertEqual(c.locationUpdateStub.invocations.count, 1)
            XCTAssertTrue(c.locationUpdateStub.invocations.first?.parameters.accuracyAuthorization == accuracyAuthorization)
        }
    }

    func testDeinit() throws {
        do {
            let locationProducer = AppleLocationProvider(
                locationManager: locationManager,
                interfaceOrientationProvider: interfaceOrientationProvider,
                mayRequestWhenInUseAuthorization: true,
                locationManagerDelegateProxy: locationManagerDelegateProxy)
            locationProducer.add(consumer: consumer)
            // reset to break a strong reference cycle from
            // locationProducer -> locationProvider -> setDelegateStub
            // -> locationProducer
            locationManager.delegate = nil
            locationManager.$delegate.reset()
        }
        XCTAssertEqual(locationManager.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationManager.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testDidUpdateLocationsUpdatesLatestLocation() {
        let location = CLLocation()

        locationProvider.locationManager(CLLocationManager(), didUpdateLocations: [CLLocation(), location])

        XCTAssertTrue(locationProvider.latestLocation?.location === location)
    }

    func testDidUpdateHeadingUpdatesLatestLocation() {
        let heading1 = CLHeading()
        let heading2 = CLHeading()
        locationProvider.locationManager(CLLocationManager(), didUpdateHeading: heading1)

        XCTAssertNil(locationProvider.latestLocation)

        locationProvider.locationManager(CLLocationManager(), didUpdateLocations: [CLLocation()])

        XCTAssertTrue(locationProvider.latestLocation?.heading === heading1)

        locationProvider.locationManager(CLLocationManager(), didUpdateHeading: heading2)

        XCTAssertTrue(locationProvider.latestLocation?.heading === heading2)
    }

    func testDidChangeAuthorizationUpdatesLatestLocation() {
        XCTAssertNil(locationProvider.latestLocation)

        locationProvider.locationManager(CLLocationManager(), didUpdateLocations: [CLLocation()])

        XCTAssertEqual(locationProvider.latestLocation?.accuracyAuthorization, .fullAccuracy)

        locationManager.compatibleAccuracyAuthorization = .reducedAccuracy

        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())

        XCTAssertEqual(locationProvider.latestLocation?.accuracyAuthorization, .reducedAccuracy)
    }

    func testStopUpdatingDuringDidUpdateLocationsDueToConsumerDeinit() throws {
        locationManager.$delegate.setStub.reset()
        autoreleasepool {
            locationProvider.add(consumer: MockLocationConsumer())
        }

        locationProvider.locationManager(CLLocationManager(), didUpdateLocations: [CLLocation()])

        XCTAssertEqual(locationManager.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationManager.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testStopUpdatingDuringDidUpdateHeadingDueToConsumerDeinit() {
        locationManager.$delegate.setStub.reset()
        autoreleasepool {
            locationProvider.add(consumer: MockLocationConsumer())
        }

        locationProvider.locationManager(CLLocationManager(), didUpdateHeading: CLHeading())

        XCTAssertEqual(locationManager.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationManager.stopUpdatingHeadingStub.invocations.count, 1)
    }

    func testStopUpdatingDuringDidFailWithErrorDueToConsumerDeinit() {
        locationManager.$delegate.setStub.reset()
        autoreleasepool {
            locationProvider.add(consumer: MockLocationConsumer())
        }

        locationProvider.locationManager(CLLocationManager(), didFailWithError: MockError())

        XCTAssertEqual(locationManager.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationManager.stopUpdatingHeadingStub.invocations.count, 1)
        XCTAssertEqual(delegate?.didFailWithErrorStub.invocations.count, 1)
    }

    func testStopUpdatingDuringDidChangeAuthorizationDueToConsumerDeinit() {
        locationManager.$delegate.setStub.reset()
        autoreleasepool {
            locationProvider.add(consumer: MockLocationConsumer())
        }

        locationManager.compatibleAccuracyAuthorization = .reducedAccuracy
        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())

        XCTAssertEqual(locationManager.stopUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationManager.stopUpdatingHeadingStub.invocations.count, 1)
        XCTAssertEqual(delegate?.didChangeAccuracyAuthorizationStub.invocations.count, 1)
    }

    func testDidFailWithErrorNotifiesDelegate() throws {
        locationProvider.add(consumer: consumer)
        let error = MockError()

        locationProvider.locationManager(CLLocationManager(), didFailWithError: error)

        XCTAssertEqual(delegate.didFailWithErrorStub.invocations.count, 1)
        XCTAssertTrue(delegate.didFailWithErrorStub.invocations.first?.parameters.locationProvider === locationProvider)
        let actualError = try XCTUnwrap(delegate.didFailWithErrorStub.invocations.first?.parameters.error)
        XCTAssertTrue((actualError as? MockError) === error)
    }

    func testShouldDisplayHeadingCalibrationUsesDelegate() {
        // given
        delegate.shouldDisplayHeadingCalibrationStub.defaultReturnValue = true

        // when
        let shouldDisplayCalibration = locationProvider.locationManagerShouldDisplayHeadingCalibration(CLLocationManager())

        // then
        XCTAssertTrue(shouldDisplayCalibration)
        XCTAssertEqual(delegate.shouldDisplayHeadingCalibrationStub.invocations.count, 1)
        XCTAssertTrue(delegate.shouldDisplayHeadingCalibrationStub.invocations.first?.parameters === locationProvider)
    }

    func testDidChangeAuthorizationNotifiesDelegateIfAccuracyAuthorizationChanged() {
        let accuracyAuthorizationValues: [CLAccuracyAuthorization] = [.fullAccuracy, .reducedAccuracy]
        let initialIndex = Int.random(in: 0...1)
        let changedIndex = (initialIndex + 1) % 2 // the other one
        locationManager.compatibleAccuracyAuthorization = accuracyAuthorizationValues[initialIndex]
        locationProvider = AppleLocationProvider(
            locationManager: locationManager,
            interfaceOrientationProvider: interfaceOrientationProvider,
            mayRequestWhenInUseAuthorization: true,
        locationManagerDelegateProxy: locationManagerDelegateProxy)
        delegate = MockLocationProducerDelegate()
        locationProvider.delegate = delegate
        locationProvider.add(consumer: consumer)
        locationManager.compatibleAccuracyAuthorization = accuracyAuthorizationValues[changedIndex]

        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())

        XCTAssertEqual(delegate.didChangeAccuracyAuthorizationStub.invocations.count, 1)
        XCTAssertTrue(delegate.didChangeAccuracyAuthorizationStub.invocations.first?.parameters.locationProvider === locationProvider)
        XCTAssertEqual(delegate.didChangeAccuracyAuthorizationStub.invocations.first?.parameters.accuracyAuthorization, locationManager.compatibleAccuracyAuthorization)
    }

    func testDidChangeAuthorizationDoesNotNotifyDelegateIfAccuracyAuthorizationDidNotChange() {
        locationManager.compatibleAccuracyAuthorization = [.fullAccuracy, .reducedAccuracy].randomElement()!
        locationProvider = AppleLocationProvider(
            locationManager: locationManager,
            interfaceOrientationProvider: interfaceOrientationProvider,
            mayRequestWhenInUseAuthorization: true,
        locationManagerDelegateProxy: locationManagerDelegateProxy)
        delegate = MockLocationProducerDelegate()
        locationProvider.delegate = delegate
        locationProvider.add(consumer: consumer)

        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())

        XCTAssertEqual(delegate.didChangeAccuracyAuthorizationStub.invocations.count, 0)
    }

    func testRequestsTemporaryFullAccuracyAuthorizationWhenAccuracyIsReduced() {
        locationProvider.add(consumer: consumer)
        locationManager.compatibleAuthorizationStatus = [.authorizedAlways, .authorizedWhenInUse].randomElement()!
        locationManager.compatibleAccuracyAuthorization = .reducedAccuracy

        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())

        if #available(iOS 14.0, *) {
            XCTAssertEqual(
                locationManager.requestTemporaryFullAccuracyAuthorizationStub.invocations.map(\.parameters),
                ["LocationAccuracyAuthorizationDescription"])
        } else {
            XCTAssertTrue(locationManager.requestTemporaryFullAccuracyAuthorizationStub.invocations.isEmpty)
        }
    }

    func testDoesNotRequestTemporaryFullAccuracyAuthorizationIfPermissionsNotGranted() {
        locationProvider.add(consumer: consumer)
        locationManager.compatibleAuthorizationStatus = [.notDetermined, .restricted, .denied].randomElement()!
        locationManager.compatibleAccuracyAuthorization = .reducedAccuracy

        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())

        XCTAssertTrue(locationManager.requestTemporaryFullAccuracyAuthorizationStub.invocations.isEmpty)
    }

    func testDoesNotRequestTemporaryFullAccuracyAuthorizationWhenAccuracyIsFull() {
        locationProvider.add(consumer: consumer)
        locationManager.compatibleAuthorizationStatus = [.authorizedAlways, .authorizedWhenInUse].randomElement()!
        locationManager.compatibleAccuracyAuthorization = .fullAccuracy

        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())

        XCTAssertTrue(locationManager.requestTemporaryFullAccuracyAuthorizationStub.invocations.isEmpty)
    }

    func testDoesNotRequestTemporaryFullAccuracyAuthorizationWhenNotUpdating() {
        locationManager.compatibleAuthorizationStatus = [.authorizedAlways, .authorizedWhenInUse].randomElement()!
        locationManager.compatibleAccuracyAuthorization = .reducedAccuracy

        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())

        XCTAssertTrue(locationManager.requestTemporaryFullAccuracyAuthorizationStub.invocations.isEmpty)
    }

    func testHeadingOrientationChangeIsPropagated() {
        // given
        let newOrientation = UIInterfaceOrientation.landscapeRight
        interfaceOrientationProvider.$interfaceOrientation.getStub.defaultReturnValue = .portraitUpsideDown
        locationProvider.add(consumer: consumer)
        locationManager.$headingOrientation.reset()

        // when
        interfaceOrientationProvider.$onInterfaceOrientationChange.send(.landscapeRight)

        // then
        XCTAssertEqual(locationManager.$headingOrientation.setStub.invocations.count, 1)
        XCTAssertEqual(locationManager.$headingOrientation.setStub.invocations.first?.parameters, CLDeviceOrientation(interfaceOrientation: newOrientation))
    }

    func testHeadingOrientationIsUpdatedInPlaceUponActivation() {
        // given
        let newOrientation = UIInterfaceOrientation.portraitUpsideDown
        interfaceOrientationProvider.$interfaceOrientation.getStub.defaultReturnValue = newOrientation
        locationProvider.add(consumer: consumer)

        // then
        XCTAssertEqual(locationManager.$headingOrientation.setStub.invocations.count, 1)
        XCTAssertEqual(locationManager.$headingOrientation.setStub.invocations.first?.parameters, CLDeviceOrientation(interfaceOrientation: newOrientation))
    }

    func testHeadingOrientationSameValueIsIgnored() {
        // given
        let orientation: UIInterfaceOrientation = .landscapeLeft
        locationManager.$headingOrientation.getStub.defaultReturnValue = CLDeviceOrientation(interfaceOrientation: orientation)
        locationProvider.add(consumer: consumer)
        interfaceOrientationProvider.$onInterfaceOrientationChange.send(orientation)
        locationManager.$headingOrientation.getStub.reset()
        locationManager.$headingOrientation.setStub.reset()

        // when
        interfaceOrientationProvider.$onInterfaceOrientationChange.send(orientation)

        // then
        XCTAssertEqual(locationManager.$headingOrientation.getStub.invocations.count, 0) // heading orientation should be cached by the provider
        XCTAssertEqual(locationManager.$headingOrientation.setStub.invocations.count, 0)
    }

    func testOptions() {
        // given
        let options = AppleLocationProvider.Options(distanceFilter: .random(in: 0...10_000),
                                                    desiredAccuracy: .random(in: 0...1000),
                                                    activityType: .other)
        // when
        locationProvider.options = options

        // then
        XCTAssertEqual(locationManager.distanceFilter, options.distanceFilter)
        XCTAssertEqual(locationManager.desiredAccuracy, options.desiredAccuracy)
        XCTAssertEqual(locationManager.activityType, options.activityType)
    }

    func testOptionsDefaultValues() {
        let locationOptions = AppleLocationProvider.Options()
        XCTAssertEqual(locationOptions.distanceFilter, kCLDistanceFilterNone)
        XCTAssertEqual(locationOptions.desiredAccuracy, kCLLocationAccuracyBest)
        XCTAssertEqual(locationOptions.activityType, .other)
    }
}
