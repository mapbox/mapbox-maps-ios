import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsLocation
import MapboxMapsFoundation
#endif

internal class LocationManagerTests: XCTestCase {

    var locationSupportableMapView: LocationSupportableMapViewMock!

    override func setUp() {
        locationSupportableMapView = LocationSupportableMapViewMock()
        super.setUp()
    }

    override func tearDown() {
        locationSupportableMapView = nil
        super.tearDown()
    }

    func testLocationManagerDefaultInitialization() {
        let locationOptions = LocationOptions()

        let locationManager = LocationManager(locationSupportableMapView: locationSupportableMapView)

        XCTAssertEqual(locationManager.options, locationOptions)
        XCTAssertTrue(locationManager.locationSupportableMapView === locationSupportableMapView)
        XCTAssertNil(locationManager.delegate)
    }

    func testAddLocationConsumer() {
        let locationManager = LocationManager(locationSupportableMapView: locationSupportableMapView)
        let locationConsumer = LocationConsumerMock()

        locationManager.addLocationConsumer(newConsumer: locationConsumer)

        XCTAssertTrue(locationManager.consumers.contains(locationConsumer))
    }

    func testUpdateLocationOptionsWithModifiedPuckType() {
        var locationOptions = LocationOptions()
        locationOptions.puckType = .puck2D(Puck2DConfiguration(scale: .constant(1.0)))
        let locationManager = LocationManager(locationSupportableMapView: locationSupportableMapView)

        var locationOptions2 = LocationOptions()
        locationOptions2.puckType = .puck2D(Puck2DConfiguration(scale: .constant(2.0)))
        locationManager.options = locationOptions2

        XCTAssertEqual(locationManager.options, locationOptions2)
        XCTAssertEqual(locationManager.locationPuckManager?.puckType, locationOptions2.puckType)
    }

    func testUpdateLocationOptionsWithPuckTypeSetToNil() {
        var locationOptions = LocationOptions()
        locationOptions.puckType = .puck2D()
        let locationManager = LocationManager(locationSupportableMapView: locationSupportableMapView)

        var locationOptions2 = LocationOptions()
        locationOptions2.puckType = nil
        locationManager.options = locationOptions2

        XCTAssertEqual(locationManager.options, locationOptions2)
        XCTAssertNil(locationManager.locationPuckManager)
    }

    func testUpdateLocationOptionsWithPuckTypeSetToNonNil() {
        var locationOptions = LocationOptions()
        locationOptions.puckType = nil
        let locationManager = LocationManager(locationSupportableMapView: locationSupportableMapView)

        var locationOptions2 = LocationOptions()
        locationOptions2.puckType = .puck2D()
        locationManager.options = locationOptions2

        XCTAssertEqual(locationManager.options, locationOptions2)
        XCTAssertEqual(locationManager.locationPuckManager?.puckType, locationOptions2.puckType)
    }
}
