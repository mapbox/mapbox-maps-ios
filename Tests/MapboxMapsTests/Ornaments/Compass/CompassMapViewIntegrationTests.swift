import XCTest
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsOrnaments
#endif

class CompassMapViewIntegrationTests: MapViewIntegrationTestCase {

    func testUpdateBearing() {
        guard let mapView = mapView else {
            XCTFail("Map view could not be found")
            return
        }
        let initialSubviews = mapView.subviews.filter { $0.isKind(of: MapboxCompassOrnamentView.self) }
        guard let compass = initialSubviews.first as? MapboxCompassOrnamentView else {
            XCTFail("Failed because compass could not be found")
            return
        }

        XCTAssertEqual(mapView.mapboxMap.cameraState.bearing, 0)
        XCTAssertTrue(compass.containerView.isHidden)
        XCTAssertEqual(mapView.mapboxMap.cameraState.bearing, compass.currentBearing)

        mapView.camera.setCamera(to: CameraOptions(bearing: 30))
        XCTAssertFalse(compass.containerView.isHidden)
        XCTAssertEqual(mapView.mapboxMap.cameraState.bearing, compass.currentBearing)
        XCTAssertEqual(mapView.mapboxMap.cameraState.bearing, 30, accuracy: 0.2)

        mapView.camera.setCamera(to: CameraOptions(bearing: 0))
        XCTAssertTrue(compass.containerView.isHidden)
        XCTAssertEqual(mapView.mapboxMap.cameraState.bearing, 0)
    }

    func testCompassTapped() {
        guard let mapView = mapView else {
            XCTFail("Map view could not be found")
            return
        }
        let initialSubviews = mapView.subviews.filter { $0.isKind(of: MapboxCompassOrnamentView.self) }
        guard let compass = initialSubviews.first as? MapboxCompassOrnamentView else {
            XCTFail("Failed because compass could not be found")
            return
        }

        mapView.camera.setCamera(to: CameraOptions(bearing: 30))

        mapView.compassTapped()

        let mapExpectation = XCTestExpectation(description: "The bearing for the map should be 0 after a tap gesture")
        let compassExpectation = XCTestExpectation(description: "The bearing for the compass should be 0 after a tap gesture.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if mapView.mapboxMap.cameraState.bearing == 0 {
                mapExpectation.fulfill()
            } else {
                XCTFail("The map's bearing is not 0 after a tap gesture.")
            }

            if compass.currentBearing == 0 {
                compassExpectation.fulfill()
            } else {
                XCTFail("The map's bearing is not 0 after a tap gesture.")
            }
        }

        wait(for: [mapExpectation, compassExpectation], timeout: 5)
    }
}
