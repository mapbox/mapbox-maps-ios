// This file is generated.

import XCTest
import Turf
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class GeoJSONSourceIntegrationTests: MapViewIntegrationTestCase {
    
    func testAdditionAndRemovalOfSource() {

        guard let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let successfullyAddedSourceExpectation = XCTestExpectation(description: "Successfully added GeoJSONSource to Map")
        successfullyAddedSourceExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedSourceExpectation = XCTestExpectation(description: "Successfully retrieved GeoJSONSource from Map")
        successfullyRetrievedSourceExpectation.expectedFulfillmentCount = 1

        style.styleURI = .streets

        didFinishLoadingStyle = { _ in
            var source = GeoJSONSource()
            source.data = GeoJSONSourceData.testSourceValue()
            source.maxzoom = Double.testSourceValue()
            source.attribution = String.testSourceValue()
            source.buffer = Double.testSourceValue()
            source.tolerance = Double.testSourceValue()
            source.cluster = Bool.testSourceValue()
            source.clusterRadius = Double.testSourceValue()
            source.clusterMaxZoom = Double.testSourceValue()
            source.lineMetrics = Bool.testSourceValue()
            source.prefetchZoomDelta = Double.testSourceValue()
            
            // Add the source
            let addResult = style.addSource(source: source, identifier: "test-source")

            switch (addResult) {
                case .success(_):
                successfullyAddedSourceExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to add GeoJSONSource because of error: \(error)")
            }

            // Retrieve the source
            let retrieveResult = style.getSource(identifier: "test-source", type: GeoJSONSource.self)

            switch (retrieveResult) {
                case .success(_):
                successfullyRetrievedSourceExpectation.fulfill()    
                case .failure(let error):
                XCTFail("Failed to retrieve GeoJSONSource because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedSourceExpectation, successfullyRetrievedSourceExpectation], timeout: 5.0)
    }
}
// End of generated file