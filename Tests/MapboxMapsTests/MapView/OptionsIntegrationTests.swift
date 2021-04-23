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

        XCTAssertEqual(mapView.gestures.gestureOptions, newConfig.gestures)
        XCTAssertEqual(mapView.camera.mapCameraOptions, newConfig.camera)
        XCTAssertEqual(mapView.location.locationOptions, newConfig.location)
        let ornaments = mapView.subviews.filter { $0.isKind(of: MapboxCompassOrnamentView.self) || $0.isKind(of: MapboxScaleBarOrnamentView.self) }

        XCTAssertEqual(ornaments.count, 2)
        XCTAssertEqual(mapView.metalView?.presentsWithTransaction, true)
    }
}
