// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class AtmosphereIntegrationTests: MapViewIntegrationTestCase {

    internal func testAddAtmosphereToMap() throws {
        let successfullyAddedObjectExpectation = XCTestExpectation(description: "Successfully added Atmosphere to Map")
        successfullyAddedObjectExpectation.expectedFulfillmentCount = 1

        let successfullyRemovedObjectExpectation = XCTestExpectation(description: "Successfully removed Atmosphere")
        successfullyRemovedObjectExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved AtmosphereLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleJSON = .testStyleJSON()

        didFinishLoadingStyle = { mapView in

            let instance = Atmosphere()
                .color(StyleColor.testConstantValue())
                .colorTransition(.testConstantValue())
                .colorUseTheme(.none)
                .highColor(StyleColor.testConstantValue())
                .highColorTransition(.testConstantValue())
                .highColorUseTheme(.none)
                .horizonBlend(Double.testConstantValue())
                .horizonBlendTransition(.testConstantValue())
                .range(start: 0, end: 1)
                .rangeTransition(.testConstantValue())
                .spaceColor(StyleColor.testConstantValue())
                .spaceColorTransition(.testConstantValue())
                .spaceColorUseTheme(.none)
                .starIntensity(Double.testConstantValue())
                .starIntensityTransition(.testConstantValue())
                .verticalRange(start: 0, end: 1)
                .verticalRangeTransition(.testConstantValue())

            // Add the Atmosphere
            do {
                try mapView.mapboxMap.setAtmosphere(instance)
                successfullyAddedObjectExpectation.fulfill()
            } catch {
                XCTFail("Failed to add AtmosphereLayer because of error: \(error)")
            }

            // Remove the Atmosphere
            do {
                try mapView.mapboxMap.removeAtmosphere()
                successfullyRemovedObjectExpectation.fulfill()
            } catch {
                XCTFail("Failed to remove AtmosphereLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedObjectExpectation, successfullyRemovedObjectExpectation], timeout: 5.0)
    }
}

// End of generated file
