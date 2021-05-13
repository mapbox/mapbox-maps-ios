import XCTest
import MapboxMaps
import CoreLocation

class StyleLoadIntegrationTests: MapViewIntegrationTestCase {

    // MARK: - Tests
    func testNilStyleDoesNotLoad() {
        guard let style = style else {
            XCTFail("Should have a valid Style object")
            return
        }

        XCTAssertNil(style.uri, "Current style should be nil.") // As set by setUp

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
        guard let style = style else {
            XCTFail("Should have a valid Style object")
            return
        }

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

        style.uri = styleURI
        wait(for: [expectation], timeout: 10)
    }
}
