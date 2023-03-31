@_spi(Experimental) @testable import MapboxMapsSwiftUI
@_spi(Package) import MapboxMaps
import CoreLocation
import XCTest

@available(iOS 13.0, *)
final class LocationCoordinatorTests: XCTestCase {
    var me: LocationCoordinator!
    var locationManager: MockLocationManager!

    override func setUpWithError() throws {
        locationManager = MockLocationManager()
        me = LocationCoordinator()

        me.setup(with: locationManager)
    }

    override func tearDownWithError() throws {
        locationManager = nil
        me = nil
    }

    func testUpdateLocationOptions() {
        let locationOptions = LocationOptions(
            distanceFilter: .random(in: 0...10),
            puckType: .puck2D(),
            puckBearingSource: [.course, .heading].randomElement()!,
            puckBearingEnabled: .random()
        )
        me.update(deps: LocationDependencies(locationOptions: locationOptions))

        XCTAssertEqual(locationOptions, locationManager.options)
    }

    func testSubscribeToLocationUpdatesOnlyIfThereAreConsumers() {
        let onLocationUpdated: LocationUpdateAction = { _ in }
        let onPuckLocationUpdated: LocationUpdateAction = { _ in }
        me.update(
            deps: LocationDependencies(locationUpdateHandlers: [onLocationUpdated], puckLocationUpdateHandlers: [onPuckLocationUpdated])
        )
        XCTAssertIdentical(locationManager.addLocationConsumerStub.invocations[0].parameters, me)
        XCTAssertIdentical(locationManager.addPuckLocationConsumerStub.invocations[0].parameters, me)

        // Verify that location updates will be subscribe once.
        locationManager.addLocationConsumerStub.reset()
        locationManager.addPuckLocationConsumerStub.reset()
        me.update(
            deps: LocationDependencies(locationUpdateHandlers: [onLocationUpdated], puckLocationUpdateHandlers: [onPuckLocationUpdated])
        )
        XCTAssertTrue(locationManager.addLocationConsumerStub.invocations.isEmpty)
        XCTAssertTrue(locationManager.addPuckLocationConsumerStub.invocations.isEmpty)

        // Verify that location updates will be unsubscribe if there are no consumers
        me.update(deps: LocationDependencies())
        XCTAssertTrue(locationManager.addLocationConsumerStub.invocations.isEmpty)
        XCTAssertTrue(locationManager.addPuckLocationConsumerStub.invocations.isEmpty)

        // Verify that location updates can be re-subscribed.
        me.update(
            deps: LocationDependencies(locationUpdateHandlers: [onLocationUpdated], puckLocationUpdateHandlers: [onPuckLocationUpdated])
        )
        XCTAssertIdentical(locationManager.addLocationConsumerStub.invocations[0].parameters, me)
        XCTAssertIdentical(locationManager.addPuckLocationConsumerStub.invocations[0].parameters, me)
    }

    func testLocationUpdate() {
        let location = Location(location: .init(latitude: .random(in: -90...90), longitude: .random(in: -180...180)), accuracyAuthorization: .reducedAccuracy)
        var receivedLocation: Location?
        let onLocationUpdated: LocationUpdateAction = { receivedLocation = $0 }
        me.update(deps: LocationDependencies(locationUpdateHandlers: [onLocationUpdated]))

        locationManager.simulateLocationUpdate(location: location)
        XCTAssertEqual(receivedLocation, location)
    }

    func testPuckLocationUpdate() {
        let location = Location(location: .init(latitude: .random(in: -90...90), longitude: .random(in: -180...180)), accuracyAuthorization: .reducedAccuracy)
        var receivedLocation: Location?
        let onPuckLocationUpdated: LocationUpdateAction = { receivedLocation = $0 }
        me.update(deps: LocationDependencies(puckLocationUpdateHandlers: [onPuckLocationUpdated]))

        locationManager.simulateLocationUpdate(location: location, isInterpolated: true)
        XCTAssertEqual(receivedLocation, location)
    }
}
