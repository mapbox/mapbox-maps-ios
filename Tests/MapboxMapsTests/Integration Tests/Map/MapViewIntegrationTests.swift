import XCTest
@testable import MapboxMaps
import MapboxCoreMaps

final class MapViewIntegrationTests: IntegrationTestCase {
    var rootView: UIView!
    var mapView: MapView!
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

        let resourceOptions = ResourceOptions(accessToken: accessToken,
                                              dataPathURL: dataPathURL)
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions)
        mapView = MapView(frame: rootView.bounds, mapInitOptions: mapInitOptions)
        rootView.addSubview(mapView)
    }

    override func tearDownWithError() throws {

        let resourceOptions = mapView?.mapboxMap.resourceOptions

        mapView?.removeFromSuperview()
        mapView = nil
        rootView = nil

        if let resourceOptions = resourceOptions {
            let expectation = self.expectation(description: "Clear map data")
            MapboxMap.clearData(for: resourceOptions) { _ in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }

        try super.tearDownWithError()
    }

    func testMapViewIsReleasedAfterCameraTransition() throws {
        weak var weakMapView: MapView?
        autoreleasepool {

            guard let rootView = rootViewController?.view else {
                XCTFail("No valid UIWindow or root view controller")
                return
            }

            let expectation = self.expectation(description: "wait for map")

            let resourceOptions = ResourceOptions(accessToken: accessToken,
                                                  dataPathURL: dataPathURL)
            let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions)
            let mapView = MapView(frame: rootView.bounds, mapInitOptions: mapInitOptions)
            weakMapView = mapView

            rootView.addSubview(mapView)

            mapView.mapboxMap.onNext(event: .mapLoaded) { [weak mapView] _ in
                let dest = CameraOptions(center: CLLocationCoordinate2D(latitude: 10, longitude: 10), zoom: 10)
                mapView?.camera.ease(to: dest, duration: 5) { (_) in
                    expectation.fulfill()
                }
            }
            wait(for: [expectation], timeout: 30.0)
            mapView.removeFromSuperview()

            XCTAssertNotNil(weakMapView)
        }
        XCTAssertNil(weakMapView)
    }

    func testViewportAndStateIsReleasedAfterTransition() throws {
        weak var weakState: ViewportState?
        weak var weakViewport: Viewport?
        weak var weakMapView: MapView?

        autoreleasepool {
            guard let rootView = rootViewController?.view else {
                XCTFail("No valid UIWindow or root view controller")
                return
            }

            let expectation = self.expectation(description: "wait for map")

            let resourceOptions = ResourceOptions(accessToken: accessToken, dataPathURL: dataPathURL)
            let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions)
            let mapView = MapView(frame: rootView.bounds, mapInitOptions: mapInitOptions)
            weakMapView = mapView
            weakViewport = mapView.viewport

            rootView.addSubview(mapView)

            mapView.mapboxMap.onNext(event: .mapLoaded) { [weak mapView] _ in
                guard let mapView = mapView else { return }
                let state = mapView.viewport.makeFollowPuckViewportState()
                weakState = state
                mapView.viewport.transition(to: state)
                expectation.fulfill()
            }

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

    func testMapViewDoesNotStartLocationServicesAutomatically() {
        let locationProvider = MockLocationProvider()

        mapView.location.overrideLocationProvider(with: locationProvider)

        XCTAssertTrue(locationProvider.startUpdatingLocationStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.startUpdatingHeadingStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.requestAlwaysAuthorizationStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.requestWhenInUseAuthorizationStub.invocations.isEmpty)
        XCTAssertTrue(locationProvider.requestTemporaryFullAccuracyAuthorizationStub.invocations.isEmpty)
    }
}
