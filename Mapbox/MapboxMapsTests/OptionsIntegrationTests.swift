import XCTest
@testable import MapboxMaps
import CoreLocation

internal class OptionsIntegrationTest: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testOptionsAreUpdated() throws {
        guard let mapView = mapView else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        var newOptions = MapboxMaps.MapOptions()
        newOptions.location.showUserLocation = true
        newOptions.camera.animationDuration = 0.1
        newOptions.gestures.scrollEnabled = false
        newOptions.ornaments.showsScale = false
        newOptions.ornaments.showsCompass = false

        mapView.update { (options) in
            options = newOptions
        }

        XCTAssert(mapView.gestureManager.gestureOptions == newOptions.gestures)
        XCTAssert(mapView.cameraManager.mapCameraOptions == newOptions.camera)
        XCTAssert(mapView.locationManager.locationOptions == newOptions.location)
        XCTAssert(!mapView.ornamentsManager.ornamentConfig.ornaments.contains(where: {$0.type == .compass
                                                                                || $0.type == .mapboxScaleBar}))
    }
}
