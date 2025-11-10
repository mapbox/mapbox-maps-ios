// This file is generated.
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class GeoJSONSourceIntegrationTests: MapViewIntegrationTestCase {

    func testAdditionAndRemovalOfSource() throws {
        let successfullyAddedSourceExpectation = XCTestExpectation(description: "Successfully added GeoJSONSourceSource to Map")
        successfullyAddedSourceExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedSourceExpectation = XCTestExpectation(description: "Successfully retrieved GeoJSONSourceSource from Map")
        successfullyRetrievedSourceExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleJSON = .testStyleJSON()

        didFinishLoadingStyle = { mapView in
            var source = GeoJSONSource(id: "test-source")
            source.data = GeoJSONSourceData.testSourceValue()
            source.maxzoom = Double.testSourceValue()
            source.minzoom = Double.testSourceValue()
            source.attribution = String.testSourceValue()
            source.buffer = Double.testSourceValue()
            source.tolerance = Double.testSourceValue()
            source.cluster = Bool.testSourceValue()
            source.clusterRadius = Double.testSourceValue()
            source.clusterMaxZoom = Double.testSourceValue()
            source.clusterMinPoints = Double.testSourceValue()
            source.lineMetrics = Bool.testSourceValue()
            source.generateId = Bool.testSourceValue()
            source.promoteId2 = Value<String>.testSourceValue()
            source.prefetchZoomDelta = Double.testSourceValue()
            source.tileCacheBudget = TileCacheBudgetSize.testSourceValue()

            // Add the source
            do {
                try mapView.mapboxMap.addSource(source)
                successfullyAddedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to add GeoJSONSource because of error: \(error)")
            }

            var result: GeoJSONSource?
            // Retrieve the source
            do {
                result = try mapView.mapboxMap.source(withId: "test-source", type: GeoJSONSource.self)
                successfullyRetrievedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve GeoJSONSource because of error: \(error)")
            }

            XCTAssertEqual(source.type, result?.type)
            XCTAssertEqual(source.promoteId2, result?.promoteId2)
            XCTAssertEqual(source.prefetchZoomDelta, result?.prefetchZoomDelta)
            XCTAssertEqual(source.tileCacheBudget, result?.tileCacheBudget)
        }

        wait(for: [successfullyAddedSourceExpectation, successfullyRetrievedSourceExpectation], timeout: 5.0)
    }
}

// End of generated file
