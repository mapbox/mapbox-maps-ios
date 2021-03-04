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
        mapView = MapView(with: rootView.bounds, resourceOptions: resourceOptions, styleURL: .streets)
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
            let mapView = MapView(with: rootView.bounds, resourceOptions: resourceOptions, styleURL: .streets)
            weakMapView = mapView

            rootView.addSubview(mapView)

            mapView.on(.mapLoadingFinished) { [weak mapView] _ in
                let dest = CameraOptions(center: CLLocationCoordinate2D(latitude: 10, longitude: 10), zoom: 10)
                mapView?.cameraManager.setCamera(to: dest, animated: true, duration: 5) { _ in
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
        XCTAssertEqual(originalFPS.fps, 30)

        let newFPS = 12
        mapView.preferredFPS = .custom(newFPS)
        XCTAssertNotEqual(originalFPS, mapView.preferredFPS)
        XCTAssertEqual(mapView.preferredFPS.fps, newFPS)
    }

    func testUpdateFromDisplayLink() {
        let originalFPS = mapView.preferredFPS
        XCTAssertNotNil(mapView.displayLink)
        mapView.preferredFPS = .lowPower
        XCTAssertNotEqual(originalFPS, mapView.preferredFPS)
        XCTAssertEqual(mapView.preferredFPS.fps, mapView.displayLink?.preferredFramesPerSecond)
    }

    func testUpdateFromDisplayLinkWhenNil() {
        mapView.displayLink = nil
        mapView.preferredFPS = .maximum

        XCTAssertNil(mapView.displayLink?.preferredFramesPerSecond)
        XCTAssertNotEqual(mapView.preferredFPS.fps, mapView.displayLink?.preferredFramesPerSecond)
    }
}
