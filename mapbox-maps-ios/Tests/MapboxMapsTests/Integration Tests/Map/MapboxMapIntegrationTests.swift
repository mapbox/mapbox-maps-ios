import XCTest
@testable import MapboxMaps

class MapboxMapIntegrationTests: IntegrationTestCase {
    var rootView: UIView!
    var mapView: MapView!
    var dataPathURL: URL!

    override func setUpWithError() throws {
        try guardForMetalDevice()

        try super.setUpWithError()

        dataPathURL = try temporaryCacheDirectory()

        guard let root = rootViewController?.view else {
            XCTFail("No valid UIWindow or root view controller")
            return
        }

        rootView = root
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        let expectation = self.expectation(description: "Clear map data")
        MapboxMapsOptions.clearData { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    // MARK: - Tests

    let styleJSONObject: [String: Any] = [
        "version": 8,
        "center": [
        -87.6298,
        41.8781
        ],
        "zoom": 12,
        "sources": [Any](),
        "layers": [Any]()
    ]

    func testLoadStyleURICompletionIsCalled() {
        setupMapView()

        let completionCalled = expectation(description: "Completion closure is called")
        mapView.mapboxMap.loadStyle(.streets) { _ in
            completionCalled.fulfill()
        }
        wait(for: [completionCalled], timeout: 5.0)
        waitForNextIdle()

        removeMapView()
    }

    func testLoadStyleJSONCompletionIsCalled() throws {
        let styleJSON = ValueConverter.toJson(forValue: styleJSONObject)
        XCTAssertFalse(styleJSON.isEmpty, "ValueConverter should create valid JSON string")

        setupMapView()

        let completionCalled = expectation(description: "Completion closure is called")
        mapView.mapboxMap.loadStyle(styleJSON) { [mapboxMap = mapView.mapboxMap] error in
            XCTAssertNil(error)
            XCTAssertEqual(styleJSON, mapboxMap?.styleJSON)
            completionCalled.fulfill()
        }
        wait(for: [completionCalled], timeout: 5.0)
        waitForNextIdle()

        removeMapView()
    }

    func testMapInitLoadsCustomStyleJSONOverURI() throws {
        let styleJSON: String = ValueConverter.toJson(forValue: styleJSONObject)
        XCTAssertFalse(styleJSON.isEmpty, "ValueConverter should create valid JSON string")

        MapboxMapsOptions.dataPath = dataPathURL
        let mapInitOptions = MapInitOptions(styleURI: .dark, styleJSON: styleJSON)
        mapView = MapView(frame: rootView.bounds, mapInitOptions: mapInitOptions)
        rootView.addSubview(mapView)

        let completionCalled = expectation(description: "Map is loaded")
        mapView.mapboxMap.onMapLoaded.observeNext { [mapboxMap = mapView.mapboxMap] _ in
            XCTAssertEqual(styleJSON, mapboxMap?.styleJSON)
            completionCalled.fulfill()
        }.store(in: &cancelables)

        wait(for: [completionCalled], timeout: 2.0)

        removeMapView()
    }

    func testMapCameraForCoordinateBoundsSetsCamera() {
        setupMapView()

        // set up initial map camera
        let initialCamera = CameraOptions(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), padding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), zoom: 1)
        mapView.mapboxMap.setCamera(to: initialCamera)

        // get new camera based on bounds and set the map to it
        let bounds = CoordinateBounds(southwest: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                                      northeast: CLLocationCoordinate2D(latitude: 1, longitude: 1))
        let newCamera = mapView.mapboxMap.camera(for: bounds, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), bearing: 100, pitch: 45, maxZoom: 2, offset: CGPoint(x: 4, y: 4))
        mapView.mapboxMap.setCamera(to: newCamera)

        XCTAssertEqual(mapView.mapboxMap.cameraState.bearing, 100)
        XCTAssertEqual(mapView.mapboxMap.cameraState.center.longitude.rounded(), newCamera.center?.longitude.rounded())
        XCTAssertEqual(mapView.mapboxMap.cameraState.center.latitude.rounded(), newCamera.center?.latitude.rounded())
        XCTAssertEqual(mapView.mapboxMap.cameraState.pitch, 45)
        XCTAssertEqual(mapView.mapboxMap.cameraState.zoom, newCamera.zoom)

        // cameraForCoordinateBounds does not return padding, so this should stay the same from the inital camera
        XCTAssertEqual(mapView.mapboxMap.cameraState.padding, UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100))

        removeMapView()
    }

    // MARK: - Helpers

    private func setupMapView() {
        MapboxMapsOptions.dataPath = dataPathURL
        mapView = MapView(frame: rootView.bounds)
        rootView.addSubview(mapView)
    }

    private func removeMapView() {
        mapView?.removeFromSuperview()
        mapView = nil
        rootView = nil
    }

    private func waitForNextIdle() {
        let waitForIdle = expectation(description: "Wait for idle")
        mapView.mapboxMap.onMapIdle.observeNext { _ in
            waitForIdle.fulfill()
        }.store(in: &cancelables)
        wait(for: [waitForIdle], timeout: 30)
    }
}
