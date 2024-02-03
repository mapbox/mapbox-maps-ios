// This file is generated.
import XCTest
@testable import MapboxMaps

final class RasterSourceIntegrationTests: MapViewIntegrationTestCase {

    func testAdditionAndRemovalOfSource() throws {
        let successfullyAddedSourceExpectation = XCTestExpectation(description: "Successfully added RasterSource to Map")
        successfullyAddedSourceExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedSourceExpectation = XCTestExpectation(description: "Successfully retrieved RasterSource from Map")
        successfullyRetrievedSourceExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in
            var source = RasterSource(id: "test-source")
            source.url = String.testSourceValue()
            source.tiles = [String].testSourceValue()
            source.bounds = [Double].testSourceValue()
            source.minzoom = Double.testSourceValue()
            source.maxzoom = Double.testSourceValue()
            source.tileSize = Double.testSourceValue()
            source.scheme = Scheme.testSourceValue()
            source.attribution = String.testSourceValue()
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
                XCTFail("Failed to add RasterSource because of error: \(error)")
            }

            // Retrieve the source
            do {
                _ = try mapView.mapboxMap.source(withId: "test-source", type: RasterSource.self)
                successfullyRetrievedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve RasterSource because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedSourceExpectation, successfullyRetrievedSourceExpectation], timeout: 5.0)
    }
}

// End of generated file
