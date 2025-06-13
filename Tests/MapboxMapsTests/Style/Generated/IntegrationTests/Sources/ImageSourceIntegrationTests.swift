// This file is generated.
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class ImageSourceIntegrationTests: MapViewIntegrationTestCase {

    func testAdditionAndRemovalOfSource() throws {
        let successfullyAddedSourceExpectation = XCTestExpectation(description: "Successfully added ImageSourceSource to Map")
        successfullyAddedSourceExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedSourceExpectation = XCTestExpectation(description: "Successfully retrieved ImageSourceSource from Map")
        successfullyRetrievedSourceExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleJSON = .testStyleJSON()

        didFinishLoadingStyle = { mapView in
            var source = ImageSource(id: "test-source")
            source.url = String.testSourceValue()
            source.coordinates = [[Double]].testSourceValue()
            source.prefetchZoomDelta = Double.testSourceValue()

            // Add the source
            do {
                try mapView.mapboxMap.addSource(source)
                successfullyAddedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to add ImageSource because of error: \(error)")
            }

            var result: ImageSource?
            // Retrieve the source
            do {
                result = try mapView.mapboxMap.source(withId: "test-source", type: ImageSource.self)
                successfullyRetrievedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve ImageSource because of error: \(error)")
            }

            XCTAssertEqual(source.type, result?.type)
            XCTAssertEqual(source.prefetchZoomDelta, result?.prefetchZoomDelta)
        }

        wait(for: [successfullyAddedSourceExpectation, successfullyRetrievedSourceExpectation], timeout: 5.0)
    }
}

// End of generated file
