import XCTest
import MetalKit

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

// swiftlint:disable explicit_top_level_acl explicit_acl
class CameraManagerTests: XCTestCase {

    var mapView: BaseMapView!
    var cameraManager: CameraManager!
    var resourceOptions: ResourceOptions!

    override func setUp() {
        resourceOptions = ResourceOptions(accessToken: "pk.feedcafedeadbeefbadebede")
        mapView = BaseMapView(with: CGRect(x: 0, y: 0, width: 100, height: 100),
                              resourceOptions: resourceOptions,
                              glyphsRasterizationOptions: GlyphsRasterizationOptions.default,
                              styleURL: nil)
        cameraManager = CameraManager(for: mapView, with: MapCameraOptions())
    }

    func testZoom() {
        XCTAssertEqual(mapView.zoom, 0.0, "Camera's zoom should match Map's default zoom.")

        mapView.cameraView.zoom = 5.0
        XCTAssertEqual(mapView.zoom, 5.0, "Camera's zoom value is not initialized.")

        cameraManager.setCamera(zoom: 10.0)

        XCTAssertEqual(mapView.zoom, 10.0, "Camera manager did not set camera view zoom value.")

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

        let camera = cameraManager.camera(for: [southwest,
                                                northwest,
                                                northeast,
                                                southeast])

        XCTAssertEqual(expectedCenter.latitude, camera.center!.latitude, accuracy: 0.25)
        XCTAssertEqual(expectedCenter.longitude, camera.center!.longitude, accuracy: 0.25)
        XCTAssertEqual(camera.bearing, 0)
        XCTAssertEqual(camera.padding, UIEdgeInsets.zero)
        XCTAssertEqual(camera.pitch, 0)
    }

    // The default bounds returned by getBounds() matches the coordinate bounds for one world. Disabling 
//    func testDefaultCameraBoundsRestrictionIsNil() {
//        let cameraManager = CameraManager(for: mapView, with: MapCameraOptions())
//
//        let restrictedBounds = cameraManager.mapCameraOptions.restrictedCoordinateBounds
//        XCTAssertNil(restrictedBounds, "Default camera options don't have set bounds restriction.")
//    }

    func testCameraOptionRestrictedBoundsRejectsBounds() {
        let restrictedBounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                                                northeast: CLLocationCoordinate2D(latitude: 10, longitude: 10))

        let outOfBounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: -10, longitude: -10),
                                           northeast: CLLocationCoordinate2D(latitude: -5, longitude: -5))

        var cameraOptions = MapCameraOptions()
        cameraOptions.restrictedCoordinateBounds = restrictedBounds
        let cameraManager = CameraManager(for: mapView, with: cameraOptions)
        let previousCenter = mapView.centerCoordinate
        cameraManager.transitionCoordinateBounds(newCoordinateBounds: outOfBounds)
        let currentCenter = mapView.centerCoordinate

        // The bounds to set the camera view to falls outside the restricted bounds,
        // so the center won't change since the call to `transitionVisibleCoordinateBounds(to:)` won't complete.
        XCTAssertEqual(previousCenter.latitude, currentCenter.latitude, "Camera view center latitude did not change.")
        XCTAssertEqual(previousCenter.longitude,
                       currentCenter.longitude,
                       "Camera view center longitude did not change.")
    }

    func testCameraForCoordinateBounds() {
        let cameraManager = CameraManager(for: mapView, with: MapCameraOptions())
        let southwest = CLLocationCoordinate2D(latitude: -10, longitude: -10)
        let northeast = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let coordinateBounds = CoordinateBounds(southwest: southwest, northeast: northeast)

        let camera = cameraManager.camera(for: coordinateBounds)
        cameraManager.fly(to: camera, completion: nil)

        XCTAssertNotNil(mapView.cameraView.camera)

        // Failing. See https://github.com/mapbox/mapbox-maps-internal/issues/396
//        XCTAssertEqual(mapView.cameraView.centerCoordinate.latitude, camera.centerCoordinate.latitude)
//        XCTAssertEqual(mapView.cameraView.centerCoordinate.longitude, camera.centerCoordinate.longitude)
    }

    func testCameraOptionRestrictedBoundsAcceptsBounds() {
        let restrictedBounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                                                northeast: CLLocationCoordinate2D(latitude: 10, longitude: 10))

        let allowedBounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: 2, longitude: 2),
                                           northeast: CLLocationCoordinate2D(latitude: 4, longitude: 4))

        var cameraOptions = MapCameraOptions()
        cameraOptions.restrictedCoordinateBounds = restrictedBounds
        let cameraManager = CameraManager(for: mapView, with: cameraOptions)
        let previousCenter = mapView.centerCoordinate
        cameraManager.transitionCoordinateBounds(newCoordinateBounds: allowedBounds)
        let currentCenter = mapView.centerCoordinate

        // The bounds to set the camera view to falls within the restricted bounds,
        // so the center will change.
        XCTAssertNotEqual(previousCenter.latitude, currentCenter.latitude, "Camera view center latitude was changed.")
        XCTAssertNotEqual(previousCenter.longitude, currentCenter.longitude,
                          "Camera view center longitude was changed.")
    }

    func testSetCamera() {

        let expectedCamera = CameraOptions(center: CLLocationCoordinate2D(latitude: 50, longitude: 50),
                                           padding: .zero,
                                           anchor: .zero,
                                           zoom: 8,
                                           bearing: .zero,
                                           pitch: 0)

        cameraManager.setCamera(to: expectedCamera, completion: nil)

        let actualCamera = mapView.cameraView.camera

        XCTAssertEqual(expectedCamera.center, actualCamera.center)
        XCTAssertEqual(expectedCamera.padding, actualCamera.padding)
        XCTAssertEqual(expectedCamera.anchor, actualCamera.anchor)
        XCTAssertEqual(expectedCamera.zoom, actualCamera.zoom)
        XCTAssertEqual(expectedCamera.bearing, actualCamera.bearing)
        XCTAssertEqual(expectedCamera.pitch, actualCamera.pitch)
    }

    func testMoveCamera() {
        mapView.cameraView.zoom = 0.0
        let initialCamera = mapView.cameraView.camera
        cameraManager.moveCamera(rotation: 10)

        XCTAssertNotEqual(initialCamera.bearing, mapView.bearing)
        XCTAssertEqual(mapView.bearing, -212.957, accuracy: 0.001, "Check that the new bearing matches the expected value.")
        XCTAssertEqual(mapView.centerCoordinate, CLLocationCoordinate2D(latitude: 0, longitude: 0))

        cameraManager.moveCamera(by: .zero, pitch: 10, zoom: 10.0)
        XCTAssertEqual(mapView.pitch, -10)
        XCTAssertEqual(mapView.zoom, 10.0, accuracy: 0.001, "The value for zoom should be 10.0")

        cameraManager.moveCamera(by: CGPoint(x: -10, y: 10))
        XCTAssertEqual(mapView.centerCoordinate.latitude, 7.013668, accuracy: 0.0001, "The new latitude should be approximately 7.013668")
        XCTAssertEqual(mapView.centerCoordinate.longitude, 7.03125, accuracy: 0.0001, "The new longitude should be approximately 7.03125")
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

        // Starting at -90 aka 270 should rotate counter clockwise to -270 aka 90
        optimizedBearing = cameraManager.optimizeBearing(startBearing: -90.0, endBearing: -270)
        XCTAssertEqual(optimizedBearing, -270)
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
}
