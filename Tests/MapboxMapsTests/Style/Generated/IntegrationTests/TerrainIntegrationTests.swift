// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class TerrainIntegrationTests: MapViewIntegrationTestCase {

    internal func testAddTerrainToMap() throws {
        let successfullyAddedObjectExpectation = XCTestExpectation(description: "Successfully added Terrain to Map")
        successfullyAddedObjectExpectation.expectedFulfillmentCount = 1

        let successfullyRemovedObjectExpectation = XCTestExpectation(description: "Successfully removed Terrain")
        successfullyRemovedObjectExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved TerrainLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleJSON = .testStyleJSON()

        didFinishLoadingStyle = { mapView in

            let instance = Terrain(sourceId: "test-terrain-source")
                .exaggeration(Double.testConstantValue())
                .exaggerationTransition(.testConstantValue())

            // Add the Terrain
            do {
                try mapView.mapboxMap.setTerrain(instance)
                successfullyAddedObjectExpectation.fulfill()
            } catch {
                XCTFail("Failed to add TerrainLayer because of error: \(error)")
            }

            // Remove the Terrain
            do {
                try mapView.mapboxMap.removeTerrain()
                successfullyRemovedObjectExpectation.fulfill()
            } catch {
                XCTFail("Failed to remove TerrainLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedObjectExpectation, successfullyRemovedObjectExpectation], timeout: 5.0)
    }
}

// End of generated file
