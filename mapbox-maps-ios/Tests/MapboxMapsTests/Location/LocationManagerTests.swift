import XCTest
@testable import MapboxMaps

final class LocationManagerTests: XCTestCase {

    var locationProvider: MockLocationProvider!
    var interpolatedLocationProducer: MockInterpolatedLocationProducer!
    var puckManager: MockPuckManager!
    var locationManager: LocationManager!
    var userInterfaceOrientationView: UIView!

    override func setUp() {
        super.setUp()
        locationProvider = MockLocationProvider()
        interpolatedLocationProducer = MockInterpolatedLocationProducer()
        puckManager = MockPuckManager()
        userInterfaceOrientationView = UIView()
        locationManager = LocationManager(
            locationProvider: locationProvider,
            interpolatedLocationProducer: interpolatedLocationProducer,
            puckManager: puckManager,
            userInterfaceOrientationView: userInterfaceOrientationView)
    }

    override func tearDown() {
        locationManager = nil
        puckManager = nil
        locationProvider = nil
        userInterfaceOrientationView = nil
        super.tearDown()
    }

    func testLocationManagerDefaultInitialization() {
        XCTAssertEqual(locationManager.options, LocationOptions())
        XCTAssertEqual(puckManager.puckType, locationManager.options.puckType)
        XCTAssertEqual(puckManager.puckBearing, locationManager.options.puckBearing)
    }

    func testOptionsArePropagatedToPuckManager() {
        var options = LocationOptions()
        options.puckType = [.puck2D(), .puck3D(Puck3DConfiguration(model: Model()))].randomElement()!
        options.puckBearing = [.heading, .course].randomElement()!
        options.puckBearingEnabled = .random()
        locationManager.options = options

        XCTAssertEqual(puckManager.puckType, options.puckType)
        XCTAssertEqual(puckManager.puckBearing, options.puckBearing)
        XCTAssertEqual(puckManager.puckBearingEnabled, options.puckBearingEnabled)
    }

    func testOptionsPropagationDoesNotInvokeLocationProviderSetterWhenItIsAClass() {
        locationManager.options = LocationOptions()

        XCTAssertTrue(interpolatedLocationProducer.$locationProvider.setStub.invocations.isEmpty)
    }

    func testOverrideLocationProvider() {
        let customLocationProvider = MockLocationProvider()

        locationManager.provider = customLocationProvider

        XCTAssertTrue(interpolatedLocationProducer.locationProvider === customLocationProvider)
    }

    func testAddLocationConsumer() {
        let consumer = MockLocationConsumer()

        locationManager.addLocationConsumer(consumer)

        XCTAssertEqual(locationProvider.addConsumerStub.invocations.count, 1)
        XCTAssertTrue(locationProvider.addConsumerStub.invocations.first?.parameters === consumer)
    }

    func testRemoveLocationConsumer() {
        let consumer = MockLocationConsumer()

        locationManager.removeLocationConsumer(consumer)

        XCTAssertEqual(locationProvider.removeConsumerStub.invocations.count, 1)
        XCTAssertTrue(locationProvider.removeConsumerStub.invocations.first?.parameters === consumer)
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
