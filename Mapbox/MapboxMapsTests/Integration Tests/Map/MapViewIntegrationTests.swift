import XCTest
import MapboxMaps
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
}
