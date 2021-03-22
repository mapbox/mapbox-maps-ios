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
        locationConsumerMock = LocationConsumerMock()
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

    func testLocationManagerShowUserLocationDefaultIsFalse() {
        let locationOptions = LocationOptions()
        XCTAssertFalse(locationOptions.showUserLocation)
    }

    func testLocationManagerPuckTypeModified() {
        var locationOptions = LocationOptions()
        locationOptions.puckType = .puck2D(Puck2DConfiguration(scale: .constant(1.0)))
        locationOptions.showUserLocation = true
        let locationManager = LocationManager(locationOptions: locationOptions,
                                              locationSupportableMapView: locationSupportableMapMock)

        var locationOptions2 = LocationOptions()
        locationOptions2.puckType = .puck2D(Puck2DConfiguration(scale: .constant(2.0)))
        locationOptions2.showUserLocation = true
        locationManager.updateLocationOptions(with: locationOptions2)
        XCTAssertEqual(locationManager.locationPuckManager?.puckType, locationOptions2.puckType)
    }

    func testLocationManagerShowUserLocationIsDisabled() {
        var locationOptions = LocationOptions()
        locationOptions.puckType = .puck2D(Puck2DConfiguration(scale: .constant(1.0)))
        locationOptions.showUserLocation = true
        let locationManager = LocationManager(locationOptions: locationOptions,
                                              locationSupportableMapView: locationSupportableMapMock)

        var locationOptions2 = LocationOptions()
        locationOptions2.showUserLocation = false
        locationManager.updateLocationOptions(with: locationOptions2)
        XCTAssertNil(locationManager.locationPuckManager)
    }

    func testLocationManagerShowUserLocationIsEnabled() {
        var locationOptions = LocationOptions()
        locationOptions.puckType = .puck2D(Puck2DConfiguration(scale: .constant(1.0)))
        locationOptions.showUserLocation = false
        let locationManager = LocationManager(locationOptions: locationOptions,
                                              locationSupportableMapView: locationSupportableMapMock)

        var locationOptions2 = LocationOptions()
        locationOptions2.puckType = .puck2D(Puck2DConfiguration(scale: .constant(2.0)))
        locationOptions2.showUserLocation = true
        locationManager.updateLocationOptions(with: locationOptions2)
        XCTAssertNotNil(locationManager.locationPuckManager)
        XCTAssertEqual(locationManager.locationPuckManager?.puckType, locationOptions2.puckType)
    }
}
