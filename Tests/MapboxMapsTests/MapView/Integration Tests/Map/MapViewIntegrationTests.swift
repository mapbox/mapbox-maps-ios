import XCTest
@testable import MapboxMaps
import MapboxCoreMaps

class MapViewIntegrationTests: IntegrationTestCase {
    var rootView: UIView!
    var mapView: MapView!
    var dataPathURL: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()

        guard let root = rootViewController?.view else {
            throw XCTSkip("No valid UIWindow or root view controller")
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
        try guardForMetalDevice()

        weak var weakMapView: MapView?
        try autoreleasepool {

            guard let rootView = rootViewController?.view else {
                throw XCTSkip("No valid UIWindow or root view controller")
            }

            let expectation = self.expectation(description: "wait for map")

            let resourceOptions = ResourceOptions(accessToken: accessToken,
                                                  dataPathURL: dataPathURL)
            let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions)
            let mapView = MapView(frame: rootView.bounds, mapInitOptions: mapInitOptions)
            weakMapView = mapView

            rootView.addSubview(mapView)

            mapView.mapboxMap.onNext(.mapLoaded) { [weak mapView] _ in
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

    func testUpdatePreferredFPS() {
        let originalFPS = mapView.preferredFramesPerSecond
        XCTAssertNotNil(originalFPS)
        XCTAssertEqual(originalFPS.rawValue, 0)

        let newFPS = 12
        mapView.preferredFramesPerSecond = PreferredFPS(rawValue: newFPS)
        XCTAssertNotEqual(originalFPS, mapView.preferredFramesPerSecond)
        XCTAssertEqual(mapView.preferredFramesPerSecond.rawValue, newFPS)
    }

    func testUpdateFromDisplayLink() {
        let originalFPS = mapView.preferredFramesPerSecond
        XCTAssertNotNil(mapView.displayLink)
        mapView.preferredFramesPerSecond = .lowPower
        XCTAssertNotEqual(originalFPS, mapView.preferredFramesPerSecond)
        XCTAssertEqual(mapView.preferredFramesPerSecond.rawValue, mapView.displayLink?.preferredFramesPerSecond)
    }

    func testAnimatorCompletionBlocksAreRemoved() {
        let firstCompletion = PendingAnimationCompletion(completion: {_ in}, animatingPosition: .end)
        let secondCompletion = PendingAnimationCompletion(completion: {_ in}, animatingPosition: .current)

        mapView.pendingAnimatorCompletionBlocks.append(firstCompletion)
        mapView.pendingAnimatorCompletionBlocks.append(secondCompletion)
        mapView.scheduleRepaint()
        XCTAssertEqual(mapView.pendingAnimatorCompletionBlocks.count, 2)

        mapView.updateFromDisplayLink(displayLink: CADisplayLink())
        XCTAssertEqual(mapView.pendingAnimatorCompletionBlocks.count, 0)
    }

    func testUpdateFromDisplayLinkWhenNil() {
        mapView.displayLink = nil
        mapView.preferredFramesPerSecond = .maximum

        XCTAssertNil(mapView.displayLink?.preferredFramesPerSecond)
        XCTAssertNotEqual(mapView.preferredFramesPerSecond.rawValue, mapView.displayLink?.preferredFramesPerSecond)
    }

    func testDataClearing() {
        defer {
            mapView?.removeFromSuperview()
            mapView = nil
        }

        guard let mapView = mapView else {
            return
        }

        let expectation = self.expectation(description: "Clear data using instance function")
        mapView.mapboxMap.clearData { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
