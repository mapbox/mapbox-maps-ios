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
        newConfig.location.puckType = nil
        newConfig.location.activityType = .automotiveNavigation
        newConfig.camera.animationDuration = 0.1
        newConfig.gestures.scrollEnabled = false

        mapView.update { (options) in
            options = newConfig
        }

        XCTAssertEqual(mapView.gestureManager.gestureOptions, newConfig.gestures)
        XCTAssertEqual(mapView.cameraManager.mapCameraOptions, newConfig.camera)
        XCTAssertEqual(mapView.locationManager.locationOptions, newConfig.location)
        XCTAssertTrue(
            mapView.ornamentsManager.ornamentConfig.ornaments.contains {
                $0.type == .compass || $0.type == .mapboxScaleBar
            }
        )
        XCTAssertEqual(mapView.metalView?.presentsWithTransaction, true)
    }
}
