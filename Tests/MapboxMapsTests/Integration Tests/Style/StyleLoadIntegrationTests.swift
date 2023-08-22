import XCTest
import MapboxMaps
import CoreLocation

class StyleLoadIntegrationTests: MapViewIntegrationTestCase {

    // MARK: - Tests
    func testNilStyleDoesNotLoad() {
        XCTAssertNil(mapView.mapboxMap.styleURI, "Current style should be nil.") // As set by setUp

        let expectation = self.expectation(description: "Style should not load")
        expectation.expectedFulfillmentCount = 1
        expectation.isInverted = true

        didFinishLoadingStyle = { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }

    func testLoadingDarkStyleURI() {
        loadAndIdle(for: .dark)
    }

    func testLoadingLightStyleURI() {
        loadAndIdle(for: .light)
    }

    func testLoadingOutdoorsStyleURI() {
        loadAndIdle(for: .outdoors)
    }

    func testLoadingSatelliteStyleURI() {
        loadAndIdle(for: .satellite)
    }

    func testLoadingSatelliteStreetsStyleURI() {
        loadAndIdle(for: .satelliteStreets)
    }

    func testLoadingStreetsStyleURI() {
        loadAndIdle(for: .streets)
    }

    func testLoadingBlueprintStyleURI() {
        loadAndIdle(for: StyleURI(rawValue: "mapbox://styles/mapbox-map-design/ck40ed2go56yr1cp7bbsalr1c")!)
    }

    // MARK: - Helpers

    private func loadAndIdle(for styleURI: StyleURI) {
        let expectation = self.expectation(description: "Wait for \(styleURI) to load")
        expectation.expectedFulfillmentCount = 2

        didFinishLoadingStyle = { _ in
            print("Loaded style \(styleURI)")
            expectation.fulfill()
        }

        didBecomeIdle = { _ in
            print("Idled")
            expectation.fulfill()
        }

        mapView.mapboxMap.styleURI = styleURI
        wait(for: [expectation], timeout: 10)
    }
}
