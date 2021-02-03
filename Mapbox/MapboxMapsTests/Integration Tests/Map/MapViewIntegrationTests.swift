import XCTest
@testable import MapboxMaps
import MapboxCoreMaps

class MapViewIntegrationTests: IntegrationTestCase {

    func testMapViewIsReleasedAfterCameraTransition() throws {
        weak var weakMapView: MapView?
        try autoreleasepool {

            guard let rootView = rootViewController?.view else {
                throw XCTSkip("No valid UIWindow or root view controller")
            }

            let expectation = self.expectation(description: "wait for map")

            let resourceOptions = ResourceOptions(accessToken: accessToken)
            let mapView = MapView(with: CGRect(origin: .zero, size: rootView.bounds.size), resourceOptions: resourceOptions, styleURL: .streets)
            weakMapView = mapView

            rootView.addSubview(mapView)

            mapView.on(.renderMapFinished) { [weak mapView] _ in
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

    func testUpdateFromDisplayLink() throws {
        guard let rootView = rootViewController?.view else {
            throw XCTSkip("No valid UIWindow or root view controller")
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken)
        let mapView = MapView(with: CGRect(origin: .zero, size: rootView.bounds.size), resourceOptions: resourceOptions, styleURL: .streets)
        rootView.addSubview(mapView)

        let originalFPS = mapView.preferredFPS

        XCTAssertNotNil(mapView.displayLink)

        mapView.preferredFPS = .lowPower

        XCTAssertNotEqual(originalFPS, mapView.preferredFPS)
        XCTAssertEqual(mapView.preferredFPS.rawValue, mapView.displayLink?.preferredFramesPerSecond)

        mapView.displayLink = nil

        mapView.preferredFPS = .maximum

        // Test that the preferredFPS are not being updated when the displayLink is nil
        XCTAssertNil(mapView.displayLink?.preferredFramesPerSecond)
        XCTAssertNotEqual(mapView.preferredFPS.rawValue, mapView.displayLink?.preferredFramesPerSecond)
        }

}
