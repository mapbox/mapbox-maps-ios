import XCTest
@testable import MapboxMaps

internal class CameraManagerIntegrationTests: MapViewIntegrationTestCase {

    var cameraManager: CameraAnimationsManager {
        guard let mapView = mapView else {
            fatalError("MapView must not be nil")
        }
        return mapView.camera
    }

    func testSetCameraEnforcesMinZoom() {

        guard let mapView = mapView else {
            XCTFail("MapView must not be nil")
            return
        }

        mapView.update(with: { (config) in
            config.camera.minimumZoomLevel = CGFloat.random(in: 0..<cameraManager.mapCameraOptions.maximumZoomLevel)
        })

        let expectedCamera = CameraOptions(zoom: -1)
        cameraManager.setCamera(to: expectedCamera)
        XCTAssertEqual(mapView.zoom, cameraManager.mapCameraOptions.minimumZoomLevel, accuracy: 0.000001)
    }

    func testSetCameraEnforcesMaxZoom() {

        guard let mapView = mapView else {
            XCTFail("MapView must not be nil")
            return
        }

        mapView.update(with: { (config) in
            config.camera.maximumZoomLevel = CGFloat.random(in: cameraManager.mapCameraOptions.minimumZoomLevel...25.5)
        })

        let expectedCamera = CameraOptions(zoom: 26)
        cameraManager.setCamera(to: expectedCamera)
        XCTAssertEqual(mapView.zoom, cameraManager.mapCameraOptions.maximumZoomLevel, accuracy: 0.000001)
    }

    func testSetCameraEnforcesMinPitch() {

        guard let mapView = mapView else {
            XCTFail("MapView must not be nil")
            return
        }

        mapView.update(with: { (config) in
            config.camera.minimumPitch = CGFloat.random(in: 0..<cameraManager.mapCameraOptions.maximumPitch)
        })

        let expectedCamera = CameraOptions(pitch: -1)
        cameraManager.setCamera(to: expectedCamera)
        XCTAssertEqual(mapView.pitch, cameraManager.mapCameraOptions.minimumPitch, accuracy: 0.000001)
    }

    func testSetCameraEnforcesMaxPitch() {

        guard let mapView = mapView else {
            XCTFail("MapView must not be nil")
            return
        }

        mapView.update(with: { (config) in
            config.camera.maximumPitch = CGFloat.random(in: cameraManager.mapCameraOptions.minimumPitch...85)
        })

        let expectedCamera = CameraOptions(pitch: 86)

        cameraManager.setCamera(to: expectedCamera)

        XCTAssertEqual(mapView.pitch, cameraManager.mapCameraOptions.maximumPitch, accuracy: 0.000001)
    }
}
