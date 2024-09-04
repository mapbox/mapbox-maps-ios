import XCTest
@testable import MapboxMaps
import MapboxCoreMaps

final class MapViewIntegrationTests: IntegrationTestCase {
    var rootView: UIView!
    var dataPathURL: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        try guardForMetalDevice()

        guard let root = rootViewController?.view else {
            XCTFail("No valid UIWindow or root view controller")
            return
        }
        rootView = root

        dataPathURL = try temporaryCacheDirectory()

        MapboxMapsOptions.dataPath = dataPathURL
    }

    override func tearDownWithError() throws {
        rootView = nil

        let expectation = self.expectation(description: "Clear map data")
        MapboxMapsOptions.clearData { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)

        try super.tearDownWithError()
    }

    func testMapViewIsReleasedAfterCameraTransition() throws {
        weak var weakMapView: MapView?
        autoreleasepool {

            guard let rootView = rootViewController?.view else {
                XCTFail("No valid UIWindow or root view controller")
                return
            }

            let mapLoadExpectation = self.expectation(description: "map is loaded")
            let animationExpectation = self.expectation(description: "camera animation is completed")

            let mapView = MapView(frame: rootView.bounds)
            weakMapView = mapView

            rootView.addSubview(mapView)

            mapView.mapboxMap.onMapLoaded.observeNext { [weak mapView] _ in
                mapLoadExpectation.fulfill()
                let dest = CameraOptions(center: CLLocationCoordinate2D(latitude: 10, longitude: 10), zoom: 10)
                mapView?.camera.ease(to: dest, duration: 5) { (_) in
                    animationExpectation.fulfill()
                }
            }.store(in: &cancelables)
            wait(for: [mapLoadExpectation, animationExpectation], timeout: 30.0)
            mapView.removeFromSuperview()

            XCTAssertNotNil(weakMapView)
        }
        XCTAssertNil(weakMapView)
    }

    func testViewportAndStateIsReleasedAfterTransition() throws {
        weak var weakState: ViewportState?
        weak var weakViewport: ViewportManager?
        weak var weakMapView: MapView?

        autoreleasepool {
            guard let rootView = rootViewController?.view else {
                XCTFail("No valid UIWindow or root view controller")
                return
            }

            let expectation = self.expectation(description: "wait for map")

            let mapView = MapView(frame: rootView.bounds)
            weakMapView = mapView
            weakViewport = mapView.viewport

            rootView.addSubview(mapView)

            mapView.mapboxMap.onMapLoaded.observeNext { [weak mapView] _ in
                guard let mapView = mapView else { return }
                let state = mapView.viewport.makeFollowPuckViewportState()
                weakState = state
                mapView.viewport.transition(to: state)
                expectation.fulfill()
            }.store(in: &cancelables)

            wait(for: [expectation], timeout: 30.0)
            mapView.removeFromSuperview()

             XCTAssertNotNil(weakState)
             XCTAssertNotNil(weakViewport)
             XCTAssertNotNil(weakMapView)
         }

        let mainQueueExpectation = expectation(description: "Main queue scheduled event")
        // appending the check to the end of the queue as some delegate notification are scheduled on the main queue
        DispatchQueue.main.async {
            mainQueueExpectation.fulfill()
            XCTAssertNil(weakState)
            XCTAssertNil(weakViewport)
            XCTAssertNil(weakMapView)
        }

        wait(for: [mainQueueExpectation], timeout: 1)
    }
}
