import XCTest
import MetalKit

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

internal class CameraManagerIntegrationTests: MapViewIntegrationTestCase {

    var cameraManager: CameraManager {
        guard let mapView = mapView else {
            fatalError("MapView must not be nil")
        }
        return mapView.cameraManager
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

class CameraManagerTests: XCTestCase {

    var mapView: BaseMapView!
    var cameraManager: CameraManager!
    var mapInitOptions: MapInitOptions!

    override func setUp() {
        mapInitOptions = MapInitOptions(resourceOptions: ResourceOptions(accessToken: "pk.feedcafedeadbeefbadebede"))

        mapView = BaseMapView(frame: CGRect(x: 0, y: 0, width: 100, height: 100),
                              mapInitOptions: mapInitOptions,
                              styleURI: nil)
        cameraManager = CameraManager(for: mapView, with: MapCameraOptions())
    }

    func testCameraForCoordinateArray() {
        // A 1:1 square
        let southwest = CLLocationCoordinate2DMake(0, 0)
        let northwest = CLLocationCoordinate2DMake(4, 0)
        let northeast = CLLocationCoordinate2DMake(4, 4)
        let southeast = CLLocationCoordinate2DMake(0, 4)

        let latitudeDelta =  northeast.latitude - southeast.latitude
        let longitudeDelta = southeast.longitude - southwest.longitude

        let expectedCenter = CLLocationCoordinate2DMake(northeast.latitude - (latitudeDelta / 2),
                                                        southeast.longitude - (longitudeDelta / 2))

        let camera = cameraManager.camera(for: [
            southwest,
            northwest,
            northeast,
            southeast
        ])

        XCTAssertEqual(expectedCenter.latitude, camera.center!.latitude, accuracy: 0.25)
        XCTAssertEqual(expectedCenter.longitude, camera.center!.longitude, accuracy: 0.25)
        XCTAssertEqual(camera.bearing, 0)
        XCTAssertEqual(camera.padding, UIEdgeInsets.zero)
        XCTAssertEqual(camera.pitch, 0)
    }

    func testOptimizeBearingClockwise() {
        let startBearing = 0.0
        let endBearing = 90.0
        let optimizedBearing = cameraManager.optimizeBearing(startBearing: startBearing, endBearing: endBearing)

        XCTAssertEqual(optimizedBearing, 90.0)
    }

    func testOptimizeBearingCounterClockwise() {
        let startBearing = 0.0
        let endBearing = 270.0
        let optimizedBearing = cameraManager.optimizeBearing(startBearing: startBearing, endBearing: endBearing)

        // We should rotate counter clockwise which is shown by a negative angle
        XCTAssertEqual(optimizedBearing, -90.0)
    }

    func testOptimizeBearingWhenBearingsAreTheSame() {
        let startBearing = -90.0
        let endBearing = 270.0
        let optimizedBearing = cameraManager.optimizeBearing(startBearing: startBearing, endBearing: endBearing)

        // -90 and 270 degrees is the same bearing so should just return original
        XCTAssertEqual(optimizedBearing, -90)
    }

    func testOptimizeBearingWhenStartBearingIsNegative() {
        var optimizedBearing: CLLocationDirection?

        // Starting at -90 aka 270 should rotate clockwise to 20
        optimizedBearing = cameraManager.optimizeBearing(startBearing: -90.0, endBearing: 20.0)
        XCTAssertEqual(optimizedBearing, 20)

        // Starting at -90 aka 270 should rotate clockwise to -270 aka 90
        optimizedBearing = cameraManager.optimizeBearing(startBearing: -90.0, endBearing: -270)
        XCTAssertEqual(optimizedBearing, 90)
    }

    func testOptimizeBearingHandlesNil() {
        var optimizedBearing: CLLocationDirection?

        // Test when no end bearing is provided
        optimizedBearing = cameraManager.optimizeBearing(startBearing: 0.0, endBearing: nil)
        XCTAssertNil(optimizedBearing)

        // Test when no start bearing is provided
        optimizedBearing = cameraManager.optimizeBearing(startBearing: nil, endBearing: 90)
        XCTAssertNil(optimizedBearing)

        // Test when no bearings are provided
        optimizedBearing = cameraManager.optimizeBearing(startBearing: nil, endBearing: nil)
        XCTAssertNil(optimizedBearing)
    }

    func testOptimizeBearingLargerThan360() {
        var optimizedBearing: CLLocationDirection?

        // 719 degrees is the same as 359 degrees. -1 should be returned because it is the shortest path from starting at 90
        optimizedBearing = cameraManager.optimizeBearing(startBearing: 90.0, endBearing: 719)
        XCTAssertEqual(optimizedBearing, -1.0)

        // -195 should be returned because it is the shortest path from starting at 180
        optimizedBearing = cameraManager.optimizeBearing(startBearing: 180, endBearing: -555)
        XCTAssertEqual(optimizedBearing, 165)

        // -160 should be returned because it is the shortest path from starting at 180
        optimizedBearing = cameraManager.optimizeBearing(startBearing: 180, endBearing: -520)
        XCTAssertEqual(optimizedBearing, 200)
    }
}
