// This file is generated.
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class RasterArraySourceIntegrationTests: MapViewIntegrationTestCase {

    func testAdditionAndRemovalOfSource() throws {
        let successfullyAddedSourceExpectation = XCTestExpectation(description: "Successfully added RasterArraySourceSource to Map")
        successfullyAddedSourceExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedSourceExpectation = XCTestExpectation(description: "Successfully retrieved RasterArraySourceSource from Map")
        successfullyRetrievedSourceExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleJSON = .testStyleJSON()

        didFinishLoadingStyle = { mapView in
            var source = RasterArraySource(id: "test-source")
            source.url = String.testSourceValue()
            source.tiles = [String].testSourceValue()
            source.extra_bounds = [[Double]].testSourceValue()
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

            var result: RasterArraySource?
            // Retrieve the source
            do {
                result = try mapView.mapboxMap.source(withId: "test-source", type: RasterArraySource.self)
                successfullyRetrievedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve RasterArraySource because of error: \(error)")
            }

            XCTAssertEqual(source.type, result?.type)
            XCTAssertEqual(source.tileCacheBudget, result?.tileCacheBudget)
        }

        wait(for: [successfullyAddedSourceExpectation, successfullyRetrievedSourceExpectation], timeout: 5.0)
    }
}

// End of generated file
