@_spi(Experimental) @testable import MapboxMaps
import CoreLocation
import XCTest

@available(iOS 13.0, *)
final class LocationCoordinatorTests: XCTestCase {
    var me: LocationCoordinator!
    var locationManager: MockLocationManager!

    override func setUpWithError() throws {
        locationManager = MockLocationManager()
        me = LocationCoordinator(locationManager: locationManager)
    }

    override func tearDownWithError() throws {
        locationManager = nil
        me = nil
    }

    func testUpdateLocationOptions() {
        let locationOptions = LocationOptions(
            puckType: .puck2D(),
            puckBearing: [.course, .heading].randomElement()!,
            puckBearingEnabled: .random()
        )
        me.update(deps: LocationDependencies(locationOptions: locationOptions))

        XCTAssertEqual(locationOptions, locationManager.options)
    }
}
