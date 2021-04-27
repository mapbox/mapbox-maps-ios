import XCTest
import MapboxMaps
import CoreLocation

internal class ExampleIntegrationTest: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        guard
            let mapView = mapView,
            let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let expectation = XCTestExpectation(description: "Wait for map to idle")
        expectation.expectedFulfillmentCount = 2

        style.uri = .streets

        didFinishLoadingStyle = { _ in
            expectation.fulfill()
        }

        didBecomeIdle = { _ in

//            if let snapshot = mapView.snapshot() {
//                let attachment = XCTAttachment(image: snapshot)
//                self.add(attachment)
//
//                // TODO: Compare images...
//                //
//            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
