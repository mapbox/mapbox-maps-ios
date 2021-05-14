import XCTest
@testable import MapboxMaps
import CoreLocation

internal class OptionsIntegrationTest: MapViewIntegrationTestCase {

    internal func testOptionsAreUpdated() throws {
        guard let mapView = mapView else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        var newConfig = MapboxMaps.MapConfig()
        newConfig.camera.animationDuration = 0.1

        mapView.update { (options) in
            options = newConfig
        }
        XCTAssertEqual(mapView.camera.mapCameraOptions, newConfig.camera)
        XCTAssertEqual(mapView.metalView?.presentsWithTransaction, true)
    }
}
