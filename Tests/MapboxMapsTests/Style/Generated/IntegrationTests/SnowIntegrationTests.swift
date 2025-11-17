// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class SnowIntegrationTests: MapViewIntegrationTestCase {

    internal func testAddSnowToMap() throws {
        let successfullyAddedObjectExpectation = XCTestExpectation(description: "Successfully added Snow to Map")
        successfullyAddedObjectExpectation.expectedFulfillmentCount = 1

        let successfullyRemovedObjectExpectation = XCTestExpectation(description: "Successfully removed Snow")
        successfullyRemovedObjectExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved SnowLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleJSON = .testStyleJSON()

        didFinishLoadingStyle = { mapView in

            let instance = Snow()
                .centerThinning(Double.testConstantValue())
                .centerThinningTransition(.testConstantValue())
                .color(StyleColor.testConstantValue())
                .colorTransition(.testConstantValue())
                .density(Double.testConstantValue())
                .densityTransition(.testConstantValue())
                .direction(azimuthal: 0, polar: 1)
                .directionTransition(.testConstantValue())
                .flakeSize(Double.testConstantValue())
                .flakeSizeTransition(.testConstantValue())
                .intensity(Double.testConstantValue())
                .intensityTransition(.testConstantValue())
                .opacity(Double.testConstantValue())
                .opacityTransition(.testConstantValue())
                .vignette(Double.testConstantValue())
                .vignetteTransition(.testConstantValue())
                .vignetteColor(StyleColor.testConstantValue())
                .vignetteColorTransition(.testConstantValue())

            // Add the Snow
            do {
                try mapView.mapboxMap.setSnow(instance)
                successfullyAddedObjectExpectation.fulfill()
            } catch {
                XCTFail("Failed to add SnowLayer because of error: \(error)")
            }

            // Remove the Snow
            do {
                try mapView.mapboxMap.removeSnow()
                successfullyRemovedObjectExpectation.fulfill()
            } catch {
                XCTFail("Failed to add SnowLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedObjectExpectation, successfullyRemovedObjectExpectation], timeout: 5.0)
    }
}

// End of generated file
