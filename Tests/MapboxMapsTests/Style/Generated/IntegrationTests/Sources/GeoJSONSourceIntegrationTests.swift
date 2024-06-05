// This file is generated.
import XCTest
@testable import MapboxMaps

final class GeoJSONSourceIntegrationTests: MapViewIntegrationTestCase {

    func testAdditionAndRemovalOfSource() throws {
        let successfullyAddedSourceExpectation = XCTestExpectation(description: "Successfully added GeoJSONSource to Map")
        successfullyAddedSourceExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedSourceExpectation = XCTestExpectation(description: "Successfully retrieved GeoJSONSource from Map")
        successfullyRetrievedSourceExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in
            var source = GeoJSONSource(id: "test-source")
            source.data = GeoJSONSourceData.testSourceValue()
            source.maxzoom = Double.testSourceValue()
            source.attribution = String.testSourceValue()
            source.buffer = Double.testSourceValue()
            source.tolerance = Double.testSourceValue()
            source.cluster = Bool.testSourceValue()
            source.clusterRadius = Double.testSourceValue()
            source.clusterMaxZoom = Double.testSourceValue()
            source.clusterMinPoints = Double.testSourceValue()
            source.lineMetrics = Bool.testSourceValue()
            source.generateId = Bool.testSourceValue()
            source.promoteId = PromoteId.testSourceValue()
            source.prefetchZoomDelta = Double.testSourceValue()
            source.tileCacheBudget = TileCacheBudgetSize.testSourceValue()

            // Add the source
            do {
                try mapView.mapboxMap.addSource(source)
                successfullyAddedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to add GeoJSONSource because of error: \(error)")
            }

            // Retrieve the source
            do {
                _ = try mapView.mapboxMap.source(withId: "test-source", type: GeoJSONSource.self)
                successfullyRetrievedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve GeoJSONSource because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedSourceExpectation, successfullyRetrievedSourceExpectation], timeout: 5.0)
    }
}

// End of generated file
