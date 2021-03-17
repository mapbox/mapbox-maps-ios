import XCTest
@testable import MapboxMaps
import CoreLocation

internal class OptionsIntegrationTest: MapViewIntegrationTestCase {

    internal func testOptionsAreUpdated() throws {
        guard let mapView = mapView else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        var newOptions = MapboxMaps.MapOptions()
        newOptions.location.puckType = nil
        newOptions.location.activityType = .automotiveNavigation
        newOptions.camera.animationDuration = 0.1
        newOptions.gestures.scrollEnabled = false
        newOptions.ornaments.showsScale = false
        newOptions.ornaments.showsCompass = false

        mapView.update { (options) in
            options = newOptions
        }

        XCTAssertEqual(mapView.gestureManager.gestureOptions, newOptions.gestures)
        XCTAssertEqual(mapView.cameraManager.mapCameraOptions, newOptions.camera)
        XCTAssertEqual(mapView.locationManager.locationOptions, newOptions.location)
        XCTAssertFalse(
            mapView.ornamentsManager.ornamentConfig.ornaments.contains {
                $0.type == .compass || $0.type == .mapboxScaleBar
            }
        )
        XCTAssertEqual(mapView.metalView?.presentsWithTransaction, true)
    }
}
