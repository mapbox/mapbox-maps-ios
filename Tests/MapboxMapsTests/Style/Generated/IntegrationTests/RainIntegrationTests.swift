// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class RainIntegrationTests: MapViewIntegrationTestCase {

    internal func testAddRainToMap() throws {
        let successfullyAddedObjectExpectation = XCTestExpectation(description: "Successfully added Rain to Map")
        successfullyAddedObjectExpectation.expectedFulfillmentCount = 1

        let successfullyRemovedObjectExpectation = XCTestExpectation(description: "Successfully removed Rain")
        successfullyRemovedObjectExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved RainLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleJSON = .testStyleJSON()

        didFinishLoadingStyle = { mapView in

            let instance = Rain()
                .centerThinning(Double.testConstantValue())
                .centerThinningTransition(.testConstantValue())
                .color(StyleColor.testConstantValue())
                .colorTransition(.testConstantValue())
                .density(Double.testConstantValue())
                .densityTransition(.testConstantValue())
                .direction(azimuthal: 0, polar: 1)
                .directionTransition(.testConstantValue())
                .intensity(Double.testConstantValue())
                .intensityTransition(.testConstantValue())
                .opacity(Double.testConstantValue())
                .opacityTransition(.testConstantValue())
                .vignette(Double.testConstantValue())
                .vignetteTransition(.testConstantValue())

            // Add the Rain
            do {
                try mapView.mapboxMap.setRain(instance)
                successfullyAddedObjectExpectation.fulfill()
            } catch {
                XCTFail("Failed to add RainLayer because of error: \(error)")
            }

            // Remove the Rain
            do {
                try mapView.mapboxMap.removeRain()
                successfullyRemovedObjectExpectation.fulfill()
            } catch {
                XCTFail("Failed to add RainLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedObjectExpectation, successfullyRemovedObjectExpectation], timeout: 5.0)
    }
}

// End of generated file
