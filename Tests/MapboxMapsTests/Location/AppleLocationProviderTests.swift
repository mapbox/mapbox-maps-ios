import XCTest
@testable import MapboxMaps

final class AppleLocationProviderTests: XCTestCase {

    var locationManager: MockCLLocationManager!
    var locationProvider: AppleLocationProvider!
    // swiftlint:disable:next weak_delegate
    var delegate: MockLocationProducerDelegate!
    var locationManagerDelegateProxy: CLLocationManagerDelegateProxy!
    var cancelables = Set<AnyCancelable>()

    @TestPublished
    var interfaceOrientation: UIInterfaceOrientation = .unknown

    override func setUp() {
        super.setUp()
        locationManager = MockCLLocationManager()
        locationManagerDelegateProxy = CLLocationManagerDelegateProxy()
        locationProvider = AppleLocationProvider(
            locationManager: locationManager,
            interfaceOrientation: $interfaceOrientation,
            mayRequestWhenInUseAuthorization: true,
            locationManagerDelegateProxy: locationManagerDelegateProxy)
        delegate = MockLocationProducerDelegate()
        locationProvider.delegate = delegate
    }

    override func tearDown() {
        cancelables.removeAll()
        delegate = nil
        locationProvider = nil
        locationManagerDelegateProxy = nil
        locationManager = nil
        super.tearDown()
    }

    // Kickstarts location updates
    private func addNoopLocationObserver() {
        locationProvider.onLocationUpdate.observe { _ in }.store(in: &cancelables)
    }

    // Kickstarts heading updates
#if !(swift(>=5.9) && os(visionOS))
    private func addNoopHeadingObserver() {
        locationProvider.onHeadingUpdate.observe { _ in }.store(in: &cancelables)
    }
#endif

    func testInitializationDoesNotStartOrStopUpdating() {
        XCTAssertTrue(locationManager.startUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationManager.stopUpdatingLocationStub.invocations.isEmpty)
#if !(swift(>=5.9) && os(visionOS))
        XCTAssertTrue(locationManager.startUpdatingHeadingStub.invocations.isEmpty)
        XCTAssertTrue(locationManager.stopUpdatingHeadingStub.invocations.isEmpty)
#endif
    }

    func testObservingLocationStartsAndStopsLocationUpdates() {
        let token = locationProvider.onLocationUpdate.observe { _ in }

        XCTAssertEqual(locationManager.startUpdatingLocationStub.invocations.count, 1)

        let token2 = locationProvider.onLocationUpdate.observe { _ in }
        XCTAssertEqual(locationManager.startUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationManager.stopUpdatingLocationStub.invocations.count, 0)

        token.cancel()
        XCTAssertEqual(locationManager.stopUpdatingLocationStub.invocations.count, 0)

        token2.cancel()
        XCTAssertEqual(locationManager.startUpdatingLocationStub.invocations.count, 1)
        XCTAssertEqual(locationManager.stopUpdatingLocationStub.invocations.count, 1)

#if !(swift(>=5.9) && os(visionOS))
        // no heading updates touched
        XCTAssertTrue(locationManager.startUpdatingHeadingStub.invocations.isEmpty)
        XCTAssertTrue(locationManager.stopUpdatingHeadingStub.invocations.isEmpty)
#endif
    }

#if !(swift(>=5.9) && os(visionOS))
    func testObservingHeadingStartsAndStopsHeadingUpdates() {
        let token = locationProvider.onHeadingUpdate.observe { _ in }

        XCTAssertEqual(locationManager.startUpdatingHeadingStub.invocations.count, 1)

        let token2 = locationProvider.onHeadingUpdate.observe { _ in }
        XCTAssertEqual(locationManager.startUpdatingHeadingStub.invocations.count, 1)
        XCTAssertEqual(locationManager.stopUpdatingHeadingStub.invocations.count, 0)

        token.cancel()
        XCTAssertEqual(locationManager.stopUpdatingHeadingStub.invocations.count, 0)

        token2.cancel()
        XCTAssertEqual(locationManager.startUpdatingHeadingStub.invocations.count, 1)
        XCTAssertEqual(locationManager.stopUpdatingHeadingStub.invocations.count, 1)

        // no location updates touched
        XCTAssertTrue(locationManager.startUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationManager.stopUpdatingLocationStub.invocations.isEmpty)
    }
#endif

    func testAddingALocationConsumerRequestsWhenInUseAuthorizationIfStatusIsNotDetermined() {
        locationManager.compatibleAuthorizationStatus = .notDetermined

        _ = locationProvider.onLocationUpdate.observe { _ in }

        XCTAssertEqual(locationManager.requestWhenInUseAuthorizationStub.invocations.count, 1)
    }

#if !(swift(>=5.9) && os(visionOS))
    func testAddingAHeadingConsumerDoesntRequestPermissions() {
        locationManager.compatibleAuthorizationStatus = .notDetermined

        _ = locationProvider.onHeadingUpdate.observe { _ in }

        XCTAssertTrue(locationManager.requestWhenInUseAuthorizationStub.invocations.isEmpty)
    }
#endif

    func testAddingALocationConsumerDoesNotRequestWhenInUseAuthorizationForOtherStatuses() {
        locationManager.compatibleAuthorizationStatus = [.restricted, .denied, .authorizedWhenInUse].randomElement()!

        _ = locationProvider.onLocationUpdate.observe { _ in }

        XCTAssertTrue(locationManager.requestWhenInUseAuthorizationStub.invocations.isEmpty)
    }

    func testAddingAConsumerDoesNotRequestWhenInUseAuthorizationIfDisallowed() {
        locationProvider = AppleLocationProvider(
            locationManager: locationManager,
            interfaceOrientation: $interfaceOrientation,
            mayRequestWhenInUseAuthorization: false,
            locationManagerDelegateProxy: locationManagerDelegateProxy)
        locationManager.compatibleAuthorizationStatus = .notDetermined

        _ = locationProvider.onLocationUpdate.observe { _ in }

        XCTAssertTrue(locationManager.requestWhenInUseAuthorizationStub.invocations.isEmpty)
    }

    func testObserversAreNotifiedOfNewLocations() {
        // Observe via object api (LocationProvider)
        var observedViaObjectAPI = [[CLLocationCoordinate2D]]()
        locationProvider.toSignal(sendCurrentValue: false).observe { (locations: [Location]) in
            observedViaObjectAPI.append(locations.map(\.coordinate))
        }.store(in: &cancelables)

        // observe via signal api
        var observed = [[CLLocationCoordinate2D]]()
        locationProvider.onLocationUpdate
            .observe {
                observed.append($0.map(\.coordinate))
            }
            .store(in: &cancelables)

        XCTAssertEqual(observed, [])
        XCTAssertEqual(observedViaObjectAPI, [])

        let locations = [
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            CLLocationCoordinate2D(latitude: 1, longitude: 1)]
        let clLocations = locations.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
        locationProvider.locationManager(CLLocationManager(), didUpdateLocations: clLocations)

        XCTAssertEqual(observed, [locations])
        XCTAssertEqual(observedViaObjectAPI, [locations])
        XCTAssertTrue(locationProvider.latestLocation?.coordinate == locations[1])
        XCTAssertTrue(locationProvider.getLastObservedLocation()?.coordinate == locations[1])
    }

#if !(swift(>=5.9) && os(visionOS))
    func testObserversAreNotifiedOfNewHeadings() {
        // Observe via object api (HeadingProvider)
        var observedViaObjectAPI = [Heading]()
        locationProvider.toSignal(sendCurrentValue: false).observe { (heading: Heading) in
            observedViaObjectAPI.append(heading)
        }.store(in: &cancelables)

        // observe via signal api
        var observed = [Heading]()
        locationProvider.onHeadingUpdate
            .observe {
                observed.append($0)
            }
            .store(in: &cancelables)

        XCTAssertEqual(observed, [])
        XCTAssertEqual(observedViaObjectAPI, observed)
        XCTAssertEqual(locationProvider.latestHeading, nil)

        let heading1 = Heading.random()
        let heading2 = Heading.random()

        let clHeading1 = MockHeading()
        clHeading1.trueHeadingStub.defaultReturnValue = heading1.direction
        clHeading1.headingAccuracyStub.defaultReturnValue = heading1.accuracy
        clHeading1.timestampStub.defaultReturnValue = heading1.timestamp

        let clHeading2 = MockHeading()
        clHeading2.trueHeadingStub.defaultReturnValue = -0.1
        clHeading2.magneticHeadingStub.defaultReturnValue = heading2.direction
        clHeading2.headingAccuracyStub.defaultReturnValue = heading2.accuracy
        clHeading2.timestampStub.defaultReturnValue = heading2.timestamp

        locationProvider.locationManager(CLLocationManager(), didUpdateHeading: clHeading1)
        locationProvider.locationManager(CLLocationManager(), didUpdateHeading: clHeading2)

        XCTAssertEqual(observed, [heading1, heading2])
        XCTAssertEqual(observedViaObjectAPI, observed)
        XCTAssertEqual(locationProvider.latestHeading, heading2)
    }
#endif

    func testConsumersAreNotifiedOfNewAccuracyAuthorizationsAfterLatestLocationIsUpdated() {
        let coordinate = CLLocationCoordinate2D.random()
        let clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let accuracyAuthorization = CLAccuracyAuthorization.reducedAccuracy

        locationManager.compatibleAccuracyAuthorization = accuracyAuthorization

        // observe via signal api
        var observed = [[Location]]()
        locationProvider.onLocationUpdate.observe {
            observed.append($0)
        }.store(in: &cancelables)

        XCTAssertEqual(observed, [])

        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())
        locationProvider.locationManager(CLLocationManager(), didUpdateLocations: [clLocation])

        let expected = Location(clLocation: clLocation, extra: Location.makeExtra(for: accuracyAuthorization))
        XCTAssertEqual(observed, [[expected]])

        locationManager.compatibleAccuracyAuthorization = .fullAccuracy
        let expected2 = Location(clLocation: clLocation, extra: Location.makeExtra(for: .fullAccuracy))
        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())
        XCTAssertEqual(observed, [[expected], [expected2]])

    }

    func testDeinit() throws {
        do {
            let locationProducer = AppleLocationProvider(
                locationManager: locationManager,
                interfaceOrientation: $interfaceOrientation,
                mayRequestWhenInUseAuthorization: true,
                locationManagerDelegateProxy: locationManagerDelegateProxy)
            locationProducer.onLocationUpdate.observe { _ in }.store(in: &cancelables)
#if !(swift(>=5.9) && os(visionOS))
            locationProducer.onHeadingUpdate.observe { _ in }.store(in: &cancelables)
#endif
            // reset to break a strong reference cycle from
            // locationProducer -> locationProvider -> setDelegateStub
            // -> locationProducer
            locationManager.delegate = nil
            locationManager.$delegate.reset()
        }
        XCTAssertEqual(locationManager.stopUpdatingLocationStub.invocations.count, 1)
#if !(swift(>=5.9) && os(visionOS))
        XCTAssertEqual(locationManager.stopUpdatingHeadingStub.invocations.count, 1)
#endif
    }

    func testDidChangeAuthorizationUpdatesLatestLocation() {
        XCTAssertNil(locationProvider.latestLocation)

        locationProvider.locationManager(CLLocationManager(), didUpdateLocations: [CLLocation()])

        XCTAssertEqual(locationProvider.latestLocation?.accuracyAuthorization, .fullAccuracy)

        locationManager.compatibleAccuracyAuthorization = .reducedAccuracy

        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())

        XCTAssertEqual(locationProvider.latestLocation?.accuracyAuthorization, .reducedAccuracy)
    }

    func testDidFailWithErrorNotifiesDelegate() throws {
        addNoopLocationObserver()
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
            interfaceOrientation: $interfaceOrientation,
            mayRequestWhenInUseAuthorization: true,
        locationManagerDelegateProxy: locationManagerDelegateProxy)
        delegate = MockLocationProducerDelegate()
        locationProvider.delegate = delegate
        addNoopLocationObserver()
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
            interfaceOrientation: $interfaceOrientation,
            mayRequestWhenInUseAuthorization: true,
        locationManagerDelegateProxy: locationManagerDelegateProxy)
        delegate = MockLocationProducerDelegate()
        locationProvider.delegate = delegate
        addNoopLocationObserver()

        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())

        XCTAssertEqual(delegate.didChangeAccuracyAuthorizationStub.invocations.count, 0)
    }

    func testRequestsTemporaryFullAccuracyAuthorizationWhenAccuracyIsReduced() {
        addNoopLocationObserver()
        locationManager.compatibleAuthorizationStatus = .authorizedWhenInUse
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
        addNoopLocationObserver()
        locationManager.compatibleAuthorizationStatus = [.notDetermined, .restricted, .denied].randomElement()!
        locationManager.compatibleAccuracyAuthorization = .reducedAccuracy

        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())

        XCTAssertTrue(locationManager.requestTemporaryFullAccuracyAuthorizationStub.invocations.isEmpty)
    }

    func testDoesNotRequestTemporaryFullAccuracyAuthorizationWhenAccuracyIsFull() {
        addNoopLocationObserver()
        locationManager.compatibleAuthorizationStatus = .authorizedWhenInUse
        locationManager.compatibleAccuracyAuthorization = .fullAccuracy

        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())

        XCTAssertTrue(locationManager.requestTemporaryFullAccuracyAuthorizationStub.invocations.isEmpty)
    }

    func testDoesNotRequestTemporaryFullAccuracyAuthorizationWhenNotUpdating() {
        locationManager.compatibleAuthorizationStatus = .authorizedWhenInUse
        locationManager.compatibleAccuracyAuthorization = .reducedAccuracy

        locationProvider.locationManagerDidChangeAuthorization(CLLocationManager())

        XCTAssertTrue(locationManager.requestTemporaryFullAccuracyAuthorizationStub.invocations.isEmpty)
    }

#if !(swift(>=5.9) && os(visionOS))
    func testHeadingOrientationChangeIsPropagated() {
        // given
        let newOrientation = UIInterfaceOrientation.landscapeRight
        interfaceOrientation = .portraitUpsideDown
        addNoopHeadingObserver()
        locationManager.$headingOrientation.reset()

        // when
        interfaceOrientation = .landscapeRight

        // then
        XCTAssertEqual(locationManager.$headingOrientation.setStub.invocations.count, 1)
        XCTAssertEqual(locationManager.$headingOrientation.setStub.invocations.first?.parameters, CLDeviceOrientation(interfaceOrientation: newOrientation))
    }

    func testHeadingOrientationIsUpdatedInPlaceUponActivation() {
        // given
        let newOrientation = UIInterfaceOrientation.portraitUpsideDown
        interfaceOrientation = newOrientation
        addNoopHeadingObserver()

        // then
        XCTAssertEqual(locationManager.$headingOrientation.setStub.invocations.count, 1)
        XCTAssertEqual(locationManager.$headingOrientation.setStub.invocations.first?.parameters, CLDeviceOrientation(interfaceOrientation: newOrientation))
    }

    func testHeadingOrientationSameValueIsIgnored() {
        // given
        let orientation: UIInterfaceOrientation = .landscapeLeft
        locationManager.$headingOrientation.getStub.defaultReturnValue = CLDeviceOrientation(interfaceOrientation: orientation)
        addNoopHeadingObserver()
        interfaceOrientation = orientation
        locationManager.$headingOrientation.getStub.reset()
        locationManager.$headingOrientation.setStub.reset()

        // when
        interfaceOrientation = orientation

        // then
        XCTAssertEqual(locationManager.$headingOrientation.getStub.invocations.count, 0) // heading orientation should be cached by the provider
        XCTAssertEqual(locationManager.$headingOrientation.setStub.invocations.count, 0)
    }
#endif

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
