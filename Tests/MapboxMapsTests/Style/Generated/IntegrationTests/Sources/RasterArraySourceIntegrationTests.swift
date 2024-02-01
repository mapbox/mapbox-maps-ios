// This file is generated.
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class RasterArraySourceIntegrationTests: MapViewIntegrationTestCase {

    func testAdditionAndRemovalOfSource() throws {
        let successfullyAddedSourceExpectation = XCTestExpectation(description: "Successfully added RasterArraySource to Map")
        successfullyAddedSourceExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedSourceExpectation = XCTestExpectation(description: "Successfully retrieved RasterArraySource from Map")
        successfullyRetrievedSourceExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in
            var source = RasterArraySource(id: "test-source")
            source.url = String.testSourceValue()
            source.tiles = [String].testSourceValue()
            source.minzoom = Double.testSourceValue()
            source.maxzoom = Double.testSourceValue()
            source.tileCacheBudget = TileCacheBudgetSize.testSourceValue()

            // Add the source
            do {
                try mapView.mapboxMap.addSource(source)
                successfullyAddedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to add RasterArraySource because of error: \(error)")
            }

            // Retrieve the source
            do {
                _ = try mapView.mapboxMap.source(withId: "test-source", type: RasterArraySource.self)
                successfullyRetrievedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve RasterArraySource because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedSourceExpectation, successfullyRetrievedSourceExpectation], timeout: 5.0)
    }
}

// End of generated file
