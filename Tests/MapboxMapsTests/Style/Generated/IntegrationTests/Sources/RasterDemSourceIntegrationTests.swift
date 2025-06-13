// This file is generated.
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class RasterDemSourceIntegrationTests: MapViewIntegrationTestCase {

    func testAdditionAndRemovalOfSource() throws {
        let successfullyAddedSourceExpectation = XCTestExpectation(description: "Successfully added RasterDemSourceSource to Map")
        successfullyAddedSourceExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedSourceExpectation = XCTestExpectation(description: "Successfully retrieved RasterDemSourceSource from Map")
        successfullyRetrievedSourceExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleJSON = .testStyleJSON()

        didFinishLoadingStyle = { mapView in
            var source = RasterDemSource(id: "test-source")
            source.url = String.testSourceValue()
            source.tiles = [String].testSourceValue()
            source.bounds = [Double].testSourceValue()
            source.minzoom = Double.testSourceValue()
            source.maxzoom = Double.testSourceValue()
            source.tileSize = Double.testSourceValue()
            source.attribution = String.testSourceValue()
            source.encoding = Encoding.testSourceValue()
            source.volatile = Bool.testSourceValue()
            source.prefetchZoomDelta = Double.testSourceValue()
            source.tileCacheBudget = TileCacheBudgetSize.testSourceValue()
            source.minimumTileUpdateInterval = Double.testSourceValue()
            source.maxOverscaleFactorForParentTiles = Double.testSourceValue()
            source.tileRequestsDelay = Double.testSourceValue()
            source.tileNetworkRequestsDelay = Double.testSourceValue()

            // Add the source
            do {
                try mapView.mapboxMap.addSource(source)
                successfullyAddedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to add RasterDemSource because of error: \(error)")
            }

            var result: RasterDemSource?
            // Retrieve the source
            do {
                result = try mapView.mapboxMap.source(withId: "test-source", type: RasterDemSource.self)
                successfullyRetrievedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve RasterDemSource because of error: \(error)")
            }

            XCTAssertEqual(source.type, result?.type)
            XCTAssertEqual(source.prefetchZoomDelta, result?.prefetchZoomDelta)
            XCTAssertEqual(source.tileCacheBudget, result?.tileCacheBudget)
            XCTAssertEqual(source.minimumTileUpdateInterval, result?.minimumTileUpdateInterval)
            XCTAssertEqual(source.maxOverscaleFactorForParentTiles, result?.maxOverscaleFactorForParentTiles)
            XCTAssertEqual(source.tileRequestsDelay, result?.tileRequestsDelay)
            XCTAssertEqual(source.tileNetworkRequestsDelay, result?.tileNetworkRequestsDelay)
        }

        wait(for: [successfullyAddedSourceExpectation, successfullyRetrievedSourceExpectation], timeout: 5.0)
    }
}

// End of generated file
