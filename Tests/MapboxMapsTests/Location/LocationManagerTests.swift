import XCTest
@testable import MapboxMaps

final class LocationManagerTests: XCTestCase {

    var locationSource: MockLocationSource!
    var puckManager: MockPuckManager!
    var locationManager: LocationManager!

    override func setUp() {
        super.setUp()
        locationSource = MockLocationSource()
        puckManager = MockPuckManager()
        locationManager = LocationManager(
            locationSource: locationSource,
            puckManager: puckManager)
    }

    override func tearDown() {
        locationManager = nil
        puckManager = nil
        locationSource = nil
        super.tearDown()
    }

    func testLocationManagerDefaultInitialization() {
        XCTAssertEqual(locationManager.options, LocationOptions())
        XCTAssertNil(locationManager.delegate)
        XCTAssertEqual(locationSource.locationProvider.locationProviderOptions, locationManager.options)
        XCTAssertEqual(puckManager.puckType, locationManager.options.puckType)
        XCTAssertEqual(puckManager.puckBearingSource, locationManager.options.puckBearingSource)
    }

    func testLatestLocationWhenLocationSourceLatestLocationIsNil() {
        locationSource.latestLocation = nil

        XCTAssertNil(locationManager.latestLocation)
    }

    func testLatestLocationWhenLocationSourceLatestLocationIsNonNil() {
        locationSource.latestLocation = Location(location: CLLocation(), heading: nil, accuracyAuthorization: .fullAccuracy)

        XCTAssertTrue(locationManager.latestLocation === locationSource.latestLocation)
    }

    func testLocationProvider() throws {
        // Note that LocationProvider is not class-bound and may be implemented by a struct or enum.
        // We should change this in the future, but for now, we cast to AnyObject. If the actual
        // value is a struct or enum, Swift automatically boxes it into an object (and this test will
        // fail since the two boxed objects wouldn't be identical), but in this situation we expect
        // it to always be a class.
        XCTAssertTrue((locationManager.locationProvider as AnyObject) === (locationSource.locationProvider as AnyObject))
    }

    func testConsumers() {
        XCTAssertTrue(locationManager.consumers === locationSource.consumers)
    }

    func testOptionsArePropagatedToLocationSourceAndPuckManager() {
        var options = LocationOptions()
        options.distanceFilter = .random(in: 0..<100)
        options.desiredAccuracy = .random(in: 0..<100)
        options.activityType = [.automotiveNavigation, .fitness, .other, .otherNavigation].randomElement()!
        options.puckType = [.puck2D(), .puck3D(Puck3DConfiguration(model: Model()))].randomElement()!
        options.puckBearingSource = [.heading, .course].randomElement()!

        locationManager.options = options

        XCTAssertEqual(locationSource.locationProvider.locationProviderOptions, options)
        XCTAssertEqual(puckManager.puckType, options.puckType)
        XCTAssertEqual(puckManager.puckBearingSource, options.puckBearingSource)
    }

    func testOverrideLocationProvider() {
        let customLocationProvider = MockLocationProvider()

        locationManager.overrideLocationProvider(with: customLocationProvider)

        // Note that LocationProvider is not class-bound and may be implemented by a struct or enum.
        // We should change this in the future, but for now, we cast to AnyObject. If the actual
        // value is a struct or enum, Swift automatically boxes it into an object (and this test will
        // fail since the boxed object wouldn't be identical to the one created above), but in this
        // situation we expect it to always be a class.
        XCTAssertTrue((locationSource.locationProvider as AnyObject) === customLocationProvider)
    }

    func testAddLocationConsumer() {
        let consumer = MockLocationConsumer()

        locationManager.addLocationConsumer(newConsumer: consumer)

        XCTAssertEqual(locationSource.addStub.invocations.count, 1)
        XCTAssertTrue(locationSource.addStub.parameters.first === consumer)
    }

    func testRemoveLocationConsumer() {
        let consumer = MockLocationConsumer()

        locationManager.removeLocationConsumer(consumer: consumer)

        XCTAssertEqual(locationSource.removeStub.invocations.count, 1)
        XCTAssertTrue(locationSource.removeStub.parameters.first === consumer)
    }

    @available(iOS 14.0, *)
    func testRequestTemporaryFullAccuracyPermissions() throws {
        let purposeKey = String.randomASCII(withLength: .random(in: 10...20))

        locationManager.requestTemporaryFullAccuracyPermissions(withPurposeKey: purposeKey)

        let locationProvider = try XCTUnwrap(locationSource.locationProvider as? MockLocationProvider)
        XCTAssertEqual(locationProvider.requestTemporaryFullAccuracyAuthorizationStub.parameters, [purposeKey])
    }

    func testLocationSourceDidFailWithError() {
        let error = MockError()
        let delegate = MockLocationPermissionsDelegate()
        locationManager.delegate = delegate

        locationManager.locationSource(locationSource, didFailWithError: error)

        XCTAssertEqual(delegate.didFailToLocateUserWithErrorStub.invocations.count, 1)
        XCTAssertTrue(delegate.didFailToLocateUserWithErrorStub.parameters.first?.locationManager === locationManager)
        XCTAssertTrue(delegate.didFailToLocateUserWithErrorStub.parameters.first?.error as? MockError === error)
    }

    func testLocationSourceDidChangeAccuracyAuthorization() {
        let accuracyAuthorization: CLAccuracyAuthorization = [.fullAccuracy, .reducedAccuracy].randomElement()!
        let delegate = MockLocationPermissionsDelegate()
        locationManager.delegate = delegate

        locationManager.locationSource(locationSource, didChangeAccuracyAuthorization: accuracyAuthorization)

        XCTAssertEqual(delegate.didChangeAccuracyAuthorizationStub.invocations.count, 1)
        XCTAssertTrue(delegate.didChangeAccuracyAuthorizationStub.parameters.first?.locationManager === locationManager)
        XCTAssertEqual(delegate.didChangeAccuracyAuthorizationStub.parameters.first?.accuracyAuthorization, accuracyAuthorization)
    }
}
