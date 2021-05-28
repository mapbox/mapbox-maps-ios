import XCTest
@testable import MapboxMaps

class CompassMapViewIntegrationTests: MapViewIntegrationTestCase {

    func testUpdateMapBearing() throws {
        let mapView = try XCTUnwrap(self.mapView, "Map view could not be found")

        let initialSubviews = mapView.subviews.filter { $0.isKind(of: MapboxCompassOrnamentView.self) }

        let compass = try XCTUnwrap(initialSubviews.first as? MapboxCompassOrnamentView, "The MapView should include a compass view as a subview")

        XCTAssertEqual(mapView.mapboxMap.cameraState.bearing, 0, "The map's initial bearing should be equal to 0")
        XCTAssertTrue(compass.containerView.isHidden, "The compass should be hidden initially")
        XCTAssertEqual(mapView.mapboxMap.cameraState.bearing, compass.currentBearing, "The map's initial bearing should be equal to the compass' bearing")

        mapView.camera.setCamera(to: CameraOptions(bearing: 30))
        XCTAssertFalse(compass.containerView.isHidden, "The compass should hidden when the bearing is 30.")
        XCTAssertEqual(mapView.mapboxMap.cameraState.bearing, compass.currentBearing, "The map's bearing should be equal to the compass' current bearing")
        XCTAssertEqual(mapView.mapboxMap.cameraState.bearing, 30, accuracy: 0.2, "The map's bearing should be equal to 30 with an accuracy of 0.2.")

        mapView.camera.setCamera(to: CameraOptions(bearing: 0))
        XCTAssertTrue(compass.containerView.isHidden)
        XCTAssertEqual(mapView.mapboxMap.cameraState.bearing, 0)
    }

    func testCompassTappedResetsToNorth() throws {
        let mapView = try XCTUnwrap(self.mapView, "Map view could not be found")

        let initialSubviews = mapView.subviews.filter { $0.isKind(of: MapboxCompassOrnamentView.self) }

        let compass = try XCTUnwrap(initialSubviews.first as? MapboxCompassOrnamentView, "The MapView should include a compass view as a subview")

        mapView.camera.setCamera(to: CameraOptions(bearing: 30))

        mapView.compassTapped()

        let mapExpectation = XCTestExpectation(description: "The bearing for the map should be 0 after a tap gesture")
        let compassExpectation = XCTestExpectation(description: "The bearing for the compass should be 0 after a tap gesture.")

        mapView.mapboxMap.onEvery(.cameraChanged) { _ in
            if mapView.mapboxMap.cameraState.bearing == 0 {
                mapExpectation.fulfill()
            }

            if compass.currentBearing == 0 {
                compassExpectation.fulfill()
            }
        }

        wait(for: [mapExpectation, compassExpectation], timeout: 5)
    }
}
