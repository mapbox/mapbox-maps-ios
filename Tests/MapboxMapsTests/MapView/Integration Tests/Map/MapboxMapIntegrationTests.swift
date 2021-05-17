import XCTest
import MapboxMaps

class MapboxMapIntegrationTests: IntegrationTestCase {
    var rootView: UIView!
    var mapView: MapView!

    override func setUpWithError() throws {
        try super.setUpWithError()

        guard let root = rootViewController?.view else {
            throw XCTSkip("No valid UIWindow or root view controller")
        }
        rootView = root
    }

    // MARK: - Tests

    func testLoadStyleURICompletionIsCalled() {
        setupMapView()

        let completionCalled = expectation(description: "Completion closure is called")
        mapView.mapboxMap.loadStyleURI(.streets) { result in
            completionCalled.fulfill()
        }
        wait(for: [completionCalled], timeout: 5.0)
        waitForNextIdle()

        removeMapView()
    }

    func testLoadStyleURICompletionIsCalledWhenMapViewIsDeallocated() {
        weak var weakMapView: MapView?
        weak var weakMapboxMap: MapboxMap?

        var completionCalled: XCTestExpectation!

        autoreleasepool {
            setupMapView()

            weakMapView = mapView
            weakMapboxMap = mapView.mapboxMap

            completionCalled = expectation(description: "Completion closure is called")
            mapView.mapboxMap.loadStyleURI(.streets) { result in
                completionCalled.fulfill()
            }

            // Now remove the MapView
            removeMapView()
        }
        
        XCTAssertNil(weakMapView)
        XCTAssertNotNil(weakMapboxMap)
        wait(for: [completionCalled], timeout: 5.0)
        XCTAssertNil(weakMapView)
        XCTAssertNil(weakMapboxMap)
    }

    // MARK: - Helpers

    private func setupMapView() {
        let resourceOptions = ResourceOptions(accessToken: accessToken)
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
        mapView.mapboxMap.onNext(.mapIdle) { _ in
            waitForIdle.fulfill()
        }
        wait(for: [waitForIdle], timeout: 30)
    }
}

