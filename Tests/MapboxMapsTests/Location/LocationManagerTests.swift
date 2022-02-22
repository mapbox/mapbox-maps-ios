import XCTest
@testable import MapboxMaps

final class LocationManagerTests: XCTestCase {

    var locationProducer: MockLocationProducer!
    var puckManager: MockPuckManager!
    var locationManager: LocationManager!

    override func setUp() {
        super.setUp()
        locationProducer = MockLocationProducer()
        puckManager = MockPuckManager()
        locationManager = LocationManager(
            locationProducer: locationProducer,
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

        assertMethodCall(locationProducer.didSetLocationProviderStub)
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

        assertMethodCall(locationProducer.addStub)
        XCTAssertTrue(locationProducer.addStub.parameters.first === consumer)
    }

    func testRemoveLocationConsumer() {
        let consumer = MockLocationConsumer()

        locationManager.removeLocationConsumer(consumer: consumer)

        assertMethodCall(locationProducer.removeStub)
        XCTAssertTrue(locationProducer.removeStub.parameters.first === consumer)
    }

    @available(iOS 14.0, *)
    func testRequestTemporaryFullAccuracyPermissions() throws {
        let purposeKey = String.randomASCII(withLength: .random(in: 10...20))

        locationManager.requestTemporaryFullAccuracyPermissions(withPurposeKey: purposeKey)

        let locationProvider = try XCTUnwrap(locationProducer.locationProvider as? MockLocationProvider)
        XCTAssertEqual(locationProvider.requestTemporaryFullAccuracyAuthorizationStub.parameters, [purposeKey])
    }

    func testLocationProducerDidFailWithError() {
        let error = MockError()
        let delegate = MockLocationPermissionsDelegate()
        locationManager.delegate = delegate

        locationManager.locationProducer(locationProducer, didFailWithError: error)

        assertMethodCall(delegate.didFailToLocateUserWithErrorStub)
        XCTAssertTrue(delegate.didFailToLocateUserWithErrorStub.parameters.first?.locationManager === locationManager)
        XCTAssertTrue(delegate.didFailToLocateUserWithErrorStub.parameters.first?.error as? MockError === error)
    }

    func testLocationProducerDidChangeAccuracyAuthorization() {
        let accuracyAuthorization: CLAccuracyAuthorization = [.fullAccuracy, .reducedAccuracy].randomElement()!
        let delegate = MockLocationPermissionsDelegate()
        locationManager.delegate = delegate

        locationManager.locationProducer(locationProducer, didChangeAccuracyAuthorization: accuracyAuthorization)

        assertMethodCall(delegate.didChangeAccuracyAuthorizationStub)
        XCTAssertTrue(delegate.didChangeAccuracyAuthorizationStub.parameters.first?.locationManager === locationManager)
        XCTAssertEqual(delegate.didChangeAccuracyAuthorizationStub.parameters.first?.accuracyAuthorization, accuracyAuthorization)
    }
}
