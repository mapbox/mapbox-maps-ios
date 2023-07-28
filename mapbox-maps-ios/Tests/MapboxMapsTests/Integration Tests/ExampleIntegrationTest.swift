import XCTest
import MapboxMaps
import CoreLocation

final class ExampleIntegrationTest: MapViewIntegrationTestCase {

    func testWaitForIdle() throws {
        let expectation = XCTestExpectation(description: "Wait for map to idle")
        expectation.expectedFulfillmentCount = 2

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { _ in
            expectation.fulfill()
        }

        didBecomeIdle = { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
