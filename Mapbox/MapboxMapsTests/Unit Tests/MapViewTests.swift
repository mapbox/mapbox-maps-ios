import XCTest
import MapboxMaps
import MapboxCoreMaps

class MapViewTests: XCTestCase {

    func testMapViewIsReleased() throws {
        weak var weakMapView: MapView?
        autoreleasepool {
            let mapView = MapView(with: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)), resourceOptions: ResourceOptions())
            weakMapView = mapView
        }
        XCTAssertNil(weakMapView)
    }

    func testDisplayLink() throws {
        weak var weakMapView: MapView?
        autoreleasepool {
            let mapView = MapView(with: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)), resourceOptions: ResourceOptions())
            weakMapView = mapView

            do {
                let displayLink = mapView.value(forKey: "displayLink")
                XCTAssertNil(displayLink)
            }

            do {
                let window = UIWindow()
                window.addSubview(mapView)
                let displayLink = mapView.value(forKey: "displayLink") as? CADisplayLink
                XCTAssertNotNil(displayLink)
                XCTAssert(!displayLink!.isPaused)
                displayLink!.isPaused = true
            }

            do {
                mapView.removeFromSuperview()
                let displayLink = mapView.value(forKey: "displayLink")
                XCTAssertNil(displayLink)
            }
            XCTAssertNotNil(weakMapView)
        }
        XCTAssertNil(weakMapView)
    }
}
