import XCTest
import MapboxMaps

class MapboxMapIntegrationTests: IntegrationTestCase {
    var rootView: UIView!
    var mapView: MapView!
    var dataPathURL: URL!

    override func setUpWithError() throws {
        try guardForMetalDevice()

        try super.setUpWithError()

        dataPathURL = try temporaryCacheDirectory()

        guard let root = rootViewController?.view else {
            throw XCTSkip("No valid UIWindow or root view controller")
        }

        rootView = root
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        if let mapView = mapView {
            let resourceOptions = mapView.mapboxMap.resourceOptions
            let expectation = self.expectation(description: "Clear map data")
            MapboxMap.clearData(for: resourceOptions) { _ in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }
    }

    // MARK: - Tests

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

        let styleJSONObject: [String: Any] = [
            "version": 8,
            "center": [
            -87.6298,
            41.8781
            ],
            "zoom": 12,
            "sources": [],
            "layers": []
        ]

        let styleJSON: String = ValueConverter.toJson(forValue: styleJSONObject)
        XCTAssertFalse(styleJSON.isEmpty, "ValueConverter should create valid JSON string")

        setupMapView()

        let completionCalled = expectation(description: "Completion closure is called")
        mapView.mapboxMap.loadStyleJSON(styleJSON) { result in
            guard case .success = result else {
                XCTFail("loadStyleJSON failed")
                return
            }
            completionCalled.fulfill()
        }
        wait(for: [completionCalled], timeout: 5.0)
        waitForNextIdle()

        removeMapView()
    }

    // MARK: - Helpers

    private func setupMapView() {
        let resourceOptions = ResourceOptions(accessToken: accessToken,
                                              dataPathURL: dataPathURL)
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions)
        mapView = MapView(frame: rootView.bounds, mapInitOptions: mapInitOptions)
        rootView.addSubview(mapView)
    }

    private func removeMapView() {
        mapView?.removeFromSuperview()
        mapView = nil
        rootView = nil
    }

    private func waitForNextIdle() {
        let waitForIdle = expectation(description: "Wait for idle")
        mapView.mapboxMap.onNext(event: .mapIdle) { _ in
            waitForIdle.fulfill()
        }
        wait(for: [waitForIdle], timeout: 30)
    }
}
