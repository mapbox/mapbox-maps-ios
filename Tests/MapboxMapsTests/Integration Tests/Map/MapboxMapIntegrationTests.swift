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
        mapView.mapboxMap.loadStyleURI(.streets) { _ in
            completionCalled.fulfill()
        }
        wait(for: [completionCalled], timeout: 5.0)
        waitForNextIdle()

        removeMapView()
    }

    func testLoadStyleJSONCompletionIsCalled() throws {
        let styleJSON: String = ValueConverter.toJson(forValue: styleJSONObject)
        XCTAssertFalse(styleJSON.isEmpty, "ValueConverter should create valid JSON string")

        setupMapView()

        let completionCalled = expectation(description: "Completion closure is called")
        mapView.mapboxMap.loadStyleJSON(styleJSON) { result in
            guard case let .success(style) = result else {
                XCTFail("loadStyleJSON failed")
                return
            }
            XCTAssertEqual(styleJSON, style.JSON)
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
        mapView.mapboxMap.onMapLoaded.observeNext { [mapView] _ in
            XCTAssertEqual(styleJSON, mapView?.mapboxMap.style.JSON)
            completionCalled.fulfill()
        }.store(in: &cancelables)

        wait(for: [completionCalled], timeout: 2.0)

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
