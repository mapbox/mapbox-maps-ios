// This file is generated.

import XCTest
import Turf
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class ImageSourceIntegrationTests: MapViewIntegrationTestCase {
    
    func testAdditionAndRemovalOfSource() throws {
        let style = try XCTUnwrap(self.style)

        let successfullyAddedSourceExpectation = XCTestExpectation(description: "Successfully added ImageSource to Map")
        successfullyAddedSourceExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedSourceExpectation = XCTestExpectation(description: "Successfully retrieved ImageSource from Map")
        successfullyRetrievedSourceExpectation.expectedFulfillmentCount = 1

        style.uri = .streets

        didFinishLoadingStyle = { _ in
            var source = ImageSource()
            source.url = String.testSourceValue()
            source.coordinates = [[Double]].testSourceValue()
            source.prefetchZoomDelta = Double.testSourceValue()
            
            // Add the source
            do {
                try style.addSource(source, id: "test-source")
                successfullyAddedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to add ImageSource because of error: \(error)")
            }

            // Retrieve the source
            do {
                _ = try style.source(withId: "test-source") as ImageSource
                successfullyRetrievedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve ImageSource because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedSourceExpectation, successfullyRetrievedSourceExpectation], timeout: 5.0)
    }
}
// End of generated file