import XCTest
import MapboxMaps
import CoreLocation

class StyleLoadIntegrationTests: MapViewIntegrationTestCase {

    // MARK: - Tests

    func testLoadingDarkStyleURL() {
        loadAndIdle(for: .dark)
    }

    func testLoadingLightStyleURL() {
        loadAndIdle(for: .light)
    }

    func testLoadingOutdoorsStyleURL() {
        loadAndIdle(for: .outdoors)
    }

    func testLoadingSatelliteStyleURL() {
        loadAndIdle(for: .satellite)
    }

    func testLoadingSatelliteStreetsStyleURL() {
        loadAndIdle(for: .satelliteStreets)
    }

    func testLoadingStreetsStyleURL() {
        loadAndIdle(for: .streets)
    }

    func testLoadingBlueprintStyleURL() {
        loadAndIdle(for: .custom(url: URL(string: "mapbox://styles/mapbox-map-design/ck40ed2go56yr1cp7bbsalr1c")!))
    }

    // MARK: - Helpers

    private func loadAndIdle(for styleURL: StyleURL) {
        guard let style = style else {
            XCTFail("Should have a valid Style object")
            return
        }

        let expectation = self.expectation(description: "Wait for \(styleURL) to load")
        expectation.expectedFulfillmentCount = 2

        didFinishLoadingStyle = { _ in
            expectation.fulfill()
        }

        didBecomeIdle = { _ in
            expectation.fulfill()
        }

        style.styleURL = styleURL
        wait(for: [expectation], timeout: 5)
    }
}
