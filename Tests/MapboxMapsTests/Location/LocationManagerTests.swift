import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsLocation
import MapboxMapsFoundation
#endif

internal class LocationManagerTests: XCTestCase {

    var locationSupportableMapMock: LocationSupportableMapViewMock!
    var locationProviderOptionsMock: LocationOptions!
    var locationConsumerMock: LocationConsumerMock!

    override func setUp() {
        locationSupportableMapMock = LocationSupportableMapViewMock()
        locationProviderOptionsMock = LocationOptions()
        locationConsumerMock = LocationConsumerMock(shouldTrackLocation: false)
        super.setUp()
    }

    override func tearDown() {
        locationSupportableMapMock = nil
        locationProviderOptionsMock = nil
        locationConsumerMock = nil
        super.tearDown()
    }

    func testLocationManagerDefaultInitialization() {
        let locationManager = LocationManager(locationOptions: locationProviderOptionsMock,
                                              locationSupportableMapView: locationSupportableMapMock)
        locationManager.addLocationConsumer(newConsumer: locationConsumerMock)

        XCTAssertNotNil(locationManager.consumers)
        XCTAssertNotNil(locationManager.locationSupportableMapView)
        XCTAssertNil(locationManager.delegate)
        XCTAssertFalse(locationManager.showUserLocation)
    }
}
