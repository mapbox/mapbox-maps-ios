import XCTest
@testable import MapboxMaps

final class LocationManagerTests: XCTestCase {

    var style: MockLocationStyle!

    override func setUp() {
        super.setUp()
        style = MockLocationStyle()
    }

    override func tearDown() {
        style = nil
        super.tearDown()
    }

    func testLocationManagerDefaultInitialization() {
        let locationOptions = LocationOptions()

        let locationManager = LocationManager(style: style)

        XCTAssertEqual(locationManager.options, locationOptions)
        XCTAssertNil(locationManager.delegate)
    }

    func testAddLocationConsumer() {
        let locationManager = LocationManager(style: style)
        let locationConsumer = LocationConsumerMock()

        locationManager.addLocationConsumer(newConsumer: locationConsumer)

        XCTAssertTrue(locationManager.consumers.contains(locationConsumer))
    }

    func testUpdateLocationOptionsWithModifiedPuckType() {
        var locationOptions = LocationOptions()
        locationOptions.puckType = .puck2D(Puck2DConfiguration(scale: .constant(1.0)))
        let locationManager = LocationManager(style: style)

        var locationOptions2 = LocationOptions()
        locationOptions2.puckType = .puck2D(Puck2DConfiguration(scale: .constant(2.0)))
        locationManager.options = locationOptions2

        XCTAssertEqual(locationManager.options, locationOptions2)
        XCTAssertEqual(locationManager.locationPuckManager?.puckType, locationOptions2.puckType)
    }

    func testUpdateLocationOptionsWithPuckTypeSetToNil() {
        var locationOptions = LocationOptions()
        locationOptions.puckType = .puck2D()
        let locationManager = LocationManager(style: style)

        var locationOptions2 = LocationOptions()
        locationOptions2.puckType = nil
        locationManager.options = locationOptions2

        XCTAssertEqual(locationManager.options, locationOptions2)
        XCTAssertNil(locationManager.locationPuckManager)
    }

    func testUpdateLocationOptionsWithPuckTypeSetToNonNil() {
        var locationOptions = LocationOptions()
        locationOptions.puckType = nil
        let locationManager = LocationManager(style: style)

        var locationOptions2 = LocationOptions()
        locationOptions2.puckType = .puck2D()
        locationManager.options = locationOptions2

        XCTAssertEqual(locationManager.options, locationOptions2)
        XCTAssertEqual(locationManager.locationPuckManager?.puckType, locationOptions2.puckType)
    }

    func testUpdateLocationOptionsWithCoursePuckBearingSource() {
        var locationOptions = LocationOptions()
        locationOptions.puckType = .puck2D()
        let locationManager = LocationManager(style: style)

        locationManager.options = locationOptions
        XCTAssertEqual(locationManager.locationPuckManager?.puckBearingSource, .heading)

        locationOptions.puckBearingSource = .course
        locationManager.options = locationOptions

        XCTAssertEqual(locationManager.options, locationOptions)
        XCTAssertEqual(locationManager.locationPuckManager?.puckBearingSource, .course)
    }

    func testLocationIsUpdatingWhenPuckTypeIsNil() {
        let locationManager = LocationManager(style: style)

        XCTAssertNil(locationManager.options.puckType)

        let locationConsumer = LocationConsumerMock()
        locationManager.addLocationConsumer(newConsumer: locationConsumer)

        // add condition that checks that location updates are still being sent
    }
}
