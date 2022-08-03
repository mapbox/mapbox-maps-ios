import XCTest
@testable import MapboxMaps

final class LocationManagerTests: XCTestCase {

    var locationProducer: MockLocationProducer!
    var interpolatedLocationProducer: MockInterpolatedLocationProducer!
    var puckManager: MockPuckManager!
    var locationManager: LocationManager!

    override func setUp() {
        super.setUp()
        locationProducer = MockLocationProducer()
        interpolatedLocationProducer = MockInterpolatedLocationProducer()
        puckManager = MockPuckManager()
        locationManager = LocationManager(
            locationProducer: locationProducer,
            interpolatedLocationProducer: interpolatedLocationProducer,
            puckManager: puckManager)
    }

    override func tearDown() {
        locationManager = nil
        puckManager = nil
        locationProducer = nil
        super.tearDown()
    }

    func testLocationManagerDefaultInitialization() {
        XCTAssertEqual(locationManager.options, LocationOptions())
        XCTAssertNil(locationManager.delegate)
        XCTAssertEqual(locationProducer.locationProvider.locationProviderOptions, locationManager.options)
        XCTAssertEqual(puckManager.puckType, locationManager.options.puckType)
        XCTAssertEqual(puckManager.puckBearingSource, locationManager.options.puckBearingSource)
    }

    func testLatestLocationWhenLocationProducerLatestLocationIsNil() {
        locationProducer.latestLocation = nil

        XCTAssertNil(locationManager.latestLocation)
    }

    func testLatestLocationWhenLocationProducerLatestLocationIsNonNil() {
        locationProducer.latestLocation = Location(location: CLLocation(), heading: nil, accuracyAuthorization: .fullAccuracy)

        XCTAssertTrue(locationManager.latestLocation === locationProducer.latestLocation)
    }

    func testLocationProvider() throws {
        // Note that LocationProvider is not class-bound and may be implemented by a struct or enum.
        // We should change this in the future, but for now, we cast to AnyObject. If the actual
        // value is a struct or enum, Swift automatically boxes it into an object (and this test will
        // fail since the two boxed objects wouldn't be identical), but in this situation we expect
        // it to always be a class.
        XCTAssertTrue((locationManager.locationProvider as AnyObject) === (locationProducer.locationProvider as AnyObject))
    }

    func testConsumers() {
        XCTAssertTrue(locationManager.consumers === locationProducer.consumers)
    }

    func testOptionsArePropagatedToLocationProducerAndPuckManager() {
        var options = LocationOptions()
        options.distanceFilter = .random(in: 0..<100)
        options.desiredAccuracy = .random(in: 0..<100)
        options.activityType = [.automotiveNavigation, .fitness, .other, .otherNavigation].randomElement()!
        options.puckType = [.puck2D(), .puck3D(Puck3DConfiguration(model: Model()))].randomElement()!
        options.puckBearingSource = [.heading, .course].randomElement()!
        options.puckBearingEnabled = .random()
        locationManager.options = options

        XCTAssertEqual(locationProducer.locationProvider.locationProviderOptions, options)
        XCTAssertEqual(puckManager.puckType, options.puckType)
        XCTAssertEqual(puckManager.puckBearingSource, options.puckBearingSource)
        XCTAssertEqual(puckManager.puckBearingEnabled, options.puckBearingEnabled)
    }

    func testOptionsPropagationDoesNotInvokeLocationProviderSetterWhenItIsAClass() {
        locationManager.options = LocationOptions()

        XCTAssertTrue(locationProducer.didSetLocationProviderStub.invocations.isEmpty)
    }

    func testOptionsPropagationDoesInvokeLocationProviderSetterWhenItIsAValueType() {
        locationManager.overrideLocationProvider(with: MockLocationProviderStruct())
        locationProducer.didSetLocationProviderStub.reset()

        locationManager.options = LocationOptions()

        XCTAssertEqual(locationProducer.didSetLocationProviderStub.invocations.count, 1)
    }

    func testOverrideLocationProvider() {
        let customLocationProvider = MockLocationProvider()

        locationManager.overrideLocationProvider(with: customLocationProvider)

        // Note that LocationProvider is not class-bound and may be implemented by a struct or enum.
        // We should change this in the future, but for now, we cast to AnyObject. If the actual
        // value is a struct or enum, Swift automatically boxes it into an object (and this test will
        // fail since the boxed object wouldn't be identical to the one created above), but in this
        // situation we expect it to always be a class.
        XCTAssertTrue((locationProducer.locationProvider as AnyObject) === customLocationProvider)
    }

    func testAddLocationConsumer() {
        let consumer = MockLocationConsumer()

        locationManager.addLocationConsumer(newConsumer: consumer)

        XCTAssertEqual(locationProducer.addStub.invocations.count, 1)
        XCTAssertTrue(locationProducer.addStub.invocations.first?.parameters === consumer)
    }

    func testRemoveLocationConsumer() {
        let consumer = MockLocationConsumer()

        locationManager.removeLocationConsumer(consumer: consumer)

        XCTAssertEqual(locationProducer.removeStub.invocations.count, 1)
        XCTAssertTrue(locationProducer.removeStub.invocations.first?.parameters === consumer)
    }

    @available(iOS 14.0, *)
    func testRequestTemporaryFullAccuracyPermissions() throws {
        let purposeKey = String.randomASCII(withLength: .random(in: 10...20))

        locationManager.requestTemporaryFullAccuracyPermissions(withPurposeKey: purposeKey)

        let locationProvider = try XCTUnwrap(locationProducer.locationProvider as? MockLocationProvider)
        XCTAssertEqual(locationProvider.requestTemporaryFullAccuracyAuthorizationStub.invocations.map(\.parameters), [purposeKey])
    }

    func testLocationProducerDidFailWithError() {
        let error = MockError()
        let delegate = MockLocationManagerDelegate()
        locationManager.delegate = delegate

        locationManager.locationProducer(locationProducer, didFailWithError: error)

        XCTAssertEqual(delegate.didFailToLocateUserWithErrorStub.invocations.count, 1)
        XCTAssertTrue(delegate.didFailToLocateUserWithErrorStub.invocations.first?.parameters.locationManager === locationManager)
        XCTAssertTrue(delegate.didFailToLocateUserWithErrorStub.invocations.first?.parameters.error as? MockError === error)
    }

    func testLocationProducerDidChangeAccuracyAuthorization() {
        let accuracyAuthorization: CLAccuracyAuthorization = [.fullAccuracy, .reducedAccuracy].randomElement()!
        let delegate = MockLocationManagerDelegate()
        locationManager.delegate = delegate

        locationManager.locationProducer(locationProducer, didChangeAccuracyAuthorization: accuracyAuthorization)

        XCTAssertEqual(delegate.didChangeAccuracyAuthorizationStub.invocations.count, 1)
        XCTAssertTrue(delegate.didChangeAccuracyAuthorizationStub.invocations.first?.parameters.locationManager === locationManager)
        XCTAssertEqual(delegate.didChangeAccuracyAuthorizationStub.invocations.first?.parameters.accuracyAuthorization, accuracyAuthorization)
    }

    func testShouldDisplayHeadingCalibrationUsesDelegate() {
        // given
        let delegate = MockLocationManagerDelegate()
        locationManager.delegate = delegate
        delegate.shouldDisplayHeadingCalibrationStub.defaultReturnValue = true

        // when
        let shouldDisplayCalibration = locationManager.locationProducerShouldDisplayHeadingCalibration(locationProducer)

        // then
        XCTAssertTrue(shouldDisplayCalibration)
        XCTAssertEqual(delegate.shouldDisplayHeadingCalibrationStub.invocations.count, 1)
        XCTAssertTrue(delegate.shouldDisplayHeadingCalibrationStub.invocations.first?.parameters === locationManager)
    }

    func testAddPuckLocationConsumer() {
        let consumer = MockPuckLocationConsumer()
        locationManager.addPuckLocationConsumer(consumer)
        XCTAssertIdentical(interpolatedLocationProducer.addPuckLocationConsumerStub.invocations.first?.parameters, consumer)
    }

    func testRemovePuckLocationConsumer() {
        let consumer = MockPuckLocationConsumer()
        locationManager.removePuckLocationConsumer(consumer)
        XCTAssertIdentical(interpolatedLocationProducer.removePuckLocationConsumerStub.invocations.first?.parameters, consumer)
    }
}
