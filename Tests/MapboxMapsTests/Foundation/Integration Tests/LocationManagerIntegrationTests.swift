import XCTest
@testable import MapboxMaps

internal class LocationManagerIntegrationTestCase: MapViewIntegrationTestCase {

    /**
        The purpose of this test is to ensure that a location manager can have a custom location provider
        The `locationManager` requires a `LocationConsumer` and therefore the full lifecycle
        here needs to be tested as an integration test. This test shows that a customer location provider
        will update the existing `locationManager`
     */
    internal func testOverrideLocationProvider() {
        style?.uri = .outdoors

        let locationManagerOverrideProvider = XCTestExpectation(description: "Checks that a new location provider can be set successfully")

        didBecomeIdle = { mapView in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                // Create a location manager
                let locationManager = self.setupLocationManager(with: mapView)

                // Retrieve the starting authorization status with the default provider
                /// The value of this should be `.notDetermined`
                let originalAuthStatus = locationManager.locationProvider.authorizationStatus

                // Create a new custom location provider and override the location manager
                let mockLocationProvider = self.setupLocationProviderMock()
                locationManager.overrideLocationProvider(with: mockLocationProvider)

                // Request always auth and then retrieve the auth status from the manager
                locationManager.locationProvider.requestAlwaysAuthorization()
                let updatedAuthStatus = locationManager.locationProvider.authorizationStatus

                // Check that we have a new auth status, which shows we have a new provider
                if updatedAuthStatus == .authorizedAlways &&
                    updatedAuthStatus != originalAuthStatus {
                    locationManagerOverrideProvider.fulfill()
                }
            }
        }

        let expectations = [locationManagerOverrideProvider]
        wait(for: expectations, timeout: 5.0)
    }

    internal func testChangePuckBearingSourceTakesEffect() {
        style?.uri = .outdoors

        let puckBearingSourceUsesHeading = XCTestExpectation(description: "Checks bearing updates are via heading")
        let puckBearingSourceUsesCourse = XCTestExpectation(description: "Checks bearing updates are via course")

        didBecomeIdle = { mapView in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                // Create a location manager
                let locationManager = self.setupLocationManager(with: mapView)

                // Sanity check for the default case
                XCTAssertEqual(locationManager.options.puckBearingSource, .heading)
                puckBearingSourceUsesHeading.fulfill()

                locationManager.options.puckBearingSource = .course
                XCTAssertEqual(locationManager.options.puckBearingSource, .course)
                puckBearingSourceUsesCourse.fulfill()
            }
        }

        let expectations = [puckBearingSourceUsesHeading, puckBearingSourceUsesCourse]
        wait(for: expectations, timeout: 5.0)
    }

    private func setupLocationManager(with mapView: MapView) -> LocationManager {
        let locationManager = LocationManager(locationSupportableMapView: mapView, style: mapView.mapboxMap.style)
        return locationManager
    }

    private func setupLocationProviderMock() -> LocationProviderMock {
        let locationProviderOptions = LocationOptions()
        return LocationProviderMock(options: locationProviderOptions)
    }
}
