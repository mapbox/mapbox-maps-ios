import XCTest
@testable import MapboxMaps
import MapboxCoreMaps

class MapViewIntegrationTests: IntegrationTestCase {
    var rootView: UIView!
    var mapView: MapView!

    override func setUpWithError() throws {
        try super.setUpWithError()

        guard let root = rootViewController?.view else {
            throw XCTSkip("No valid UIWindow or root view controller")
        }
        rootView = root

        let resourceOptions = ResourceOptions(accessToken: accessToken)
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions)
        mapView = MapView(frame: rootView.bounds, mapInitOptions: mapInitOptions)
        rootView.addSubview(mapView)
    }

    func testMapViewIsReleasedAfterCameraTransition() throws {
        weak var weakMapView: MapView?
        try autoreleasepool {

            guard let rootView = rootViewController?.view else {
                throw XCTSkip("No valid UIWindow or root view controller")
            }

            let expectation = self.expectation(description: "wait for map")

            let resourceOptions = ResourceOptions(accessToken: accessToken)
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
        let originalFPS = mapView.preferredFPS
        XCTAssertNotNil(originalFPS)
        XCTAssertEqual(originalFPS.rawValue, -1)

        let newFPS = 12
        mapView.preferredFPS = PreferredFPS(rawValue: newFPS)
        XCTAssertNotEqual(originalFPS, mapView.preferredFPS)
        XCTAssertEqual(mapView.preferredFPS.rawValue, newFPS)
    }

    func testUpdateFromDisplayLink() {
        let originalFPS = mapView.preferredFPS
        XCTAssertNotNil(mapView.displayLink)
        mapView.preferredFPS = .lowPower
        XCTAssertNotEqual(originalFPS, mapView.preferredFPS)
        XCTAssertEqual(mapView.preferredFPS.rawValue, mapView.displayLink?.preferredFramesPerSecond)
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
        mapView.preferredFPS = .maximum

        XCTAssertNil(mapView.displayLink?.preferredFramesPerSecond)
        XCTAssertNotEqual(mapView.preferredFPS.rawValue, mapView.displayLink?.preferredFramesPerSecond)
    }

    func testLoadStyleURICompletionIsCalled() {
        let completionCalled = expectation(description: "Completion closure is called")
        mapView.mapboxMap.loadStyleURI(.streets) { result in
            completionCalled.fulfill()
        }
        wait(for: [completionCalled], timeout: 5.0)
        waitForNextIdle()
    }

    func testLoadStyleURICompletionIsCalledWhenMapViewIsDeallocated() {
        mapView.removeFromSuperview()
        mapView = nil


        weak var weakMapView: MapView?
        weak var weakMapboxMap: MapboxMap?
        var completionCalled: XCTestExpectation!

        autoreleasepool {
            let resourceOptions = ResourceOptions(accessToken: accessToken)
            let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions)
            mapView = MapView(frame: rootView.bounds, mapInitOptions: mapInitOptions)
            rootView.addSubview(mapView)


            weakMapView = mapView
            weakMapboxMap = mapView.mapboxMap

            completionCalled = expectation(description: "Completion closure is called")
            mapView.mapboxMap.loadStyleURI(.streets) { result in
                completionCalled.fulfill()
            }

            mapView.removeFromSuperview()
            mapView = nil
        }
        XCTAssertNil(weakMapView)
        XCTAssertNotNil(weakMapboxMap)
        wait(for: [completionCalled], timeout: 5.0)
        XCTAssertNil(weakMapView)
        XCTAssertNil(weakMapboxMap)
    }

    private func waitForNextIdle() {
        let waitForIdle = expectation(description: "Wait for idle")
        mapView.mapboxMap.onNext(.mapIdle) { _ in
            waitForIdle.fulfill()
        }
        wait(for: [waitForIdle], timeout: 30)
    }

}
