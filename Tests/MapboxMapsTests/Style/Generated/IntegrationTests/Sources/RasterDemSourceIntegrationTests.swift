// This file is generated.

import XCTest
import Turf
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class RasterDemSourceIntegrationTests: MapViewIntegrationTestCase {
    
    func testAdditionAndRemovalOfSource() {

        guard let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let successfullyAddedSourceExpectation = XCTestExpectation(description: "Successfully added RasterDemSource to Map")
        successfullyAddedSourceExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedSourceExpectation = XCTestExpectation(description: "Successfully retrieved RasterDemSource from Map")
        successfullyRetrievedSourceExpectation.expectedFulfillmentCount = 1

        style.styleURI = .streets

        didFinishLoadingStyle = { _ in
            var source = RasterDemSource()
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
            source.minimumTileUpdateInterval = Double.testSourceValue()
            source.maxOverscaleFactorForParentTiles = Double.testSourceValue()
            
            // Add the source
            let addResult = style.addSource(source: source, identifier: "test-source")

            switch (addResult) {
                case .success(_):
                successfullyAddedSourceExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to add RasterDemSource because of error: \(error)")
            }

            // Retrieve the source
            let retrieveResult = style.getSource(identifier: "test-source", type: RasterDemSource.self)

            switch (retrieveResult) {
                case .success(_):
                successfullyRetrievedSourceExpectation.fulfill()    
                case .failure(let error):
                XCTFail("Failed to retrieve RasterDemSource because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedSourceExpectation, successfullyRetrievedSourceExpectation], timeout: 5.0)
    }
}
// End of generated file