// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class SnowIntegrationTests: MapViewIntegrationTestCase {

    internal func testAddSnowToMap() throws {
        let successfullyAddedObjectExpectation = XCTestExpectation(description: "Successfully added Snow to Map")
        successfullyAddedObjectExpectation.expectedFulfillmentCount = 1

        let successfullyRemovedObjectExpectation = XCTestExpectation(description: "Successfully removed Snow")
        successfullyRemovedObjectExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleJSON = .testStyleJSON()

        didFinishLoadingStyle = { mapView in

            let instance = Snow()
                .centerThinning(Double.testConstantValue())
                .centerThinningTransition(.testConstantValue())
                .color(StyleColor.testConstantValue())
                .colorTransition(.testConstantValue())
                .colorUseTheme(.none)
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
                .vignetteColorUseTheme(.none)

            // Add the Snow
            do {
                try mapView.mapboxMap.setSnow(instance)
                successfullyAddedObjectExpectation.fulfill()
                assertCoreStoredStyleProperty("center-thinning", stored: mapView.mapboxMap.snowProperty("center-thinning"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("center-thinning-transition", stored: mapView.mapboxMap.snowProperty("center-thinning-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("color", stored: mapView.mapboxMap.snowProperty("color"), equals: .color(StyleColor.testConstantValue()))
                assertCoreStoredStyleProperty("color-transition", stored: mapView.mapboxMap.snowProperty("color-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("color-use-theme", stored: mapView.mapboxMap.snowProperty("color-use-theme"), equals: .string(ColorUseTheme.none.rawValue))
                assertCoreStoredStyleProperty("density", stored: mapView.mapboxMap.snowProperty("density"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("density-transition", stored: mapView.mapboxMap.snowProperty("density-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("direction", stored: mapView.mapboxMap.snowProperty("direction"), equals: .array([0, 1]))
                assertCoreStoredStyleProperty("direction-transition", stored: mapView.mapboxMap.snowProperty("direction-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("flake-size", stored: mapView.mapboxMap.snowProperty("flake-size"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("flake-size-transition", stored: mapView.mapboxMap.snowProperty("flake-size-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("intensity", stored: mapView.mapboxMap.snowProperty("intensity"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("intensity-transition", stored: mapView.mapboxMap.snowProperty("intensity-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("opacity", stored: mapView.mapboxMap.snowProperty("opacity"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("opacity-transition", stored: mapView.mapboxMap.snowProperty("opacity-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("vignette", stored: mapView.mapboxMap.snowProperty("vignette"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("vignette-transition", stored: mapView.mapboxMap.snowProperty("vignette-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("vignette-color", stored: mapView.mapboxMap.snowProperty("vignette-color"), equals: .color(StyleColor.testConstantValue()))
                assertCoreStoredStyleProperty("vignette-color-transition", stored: mapView.mapboxMap.snowProperty("vignette-color-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("vignette-color-use-theme", stored: mapView.mapboxMap.snowProperty("vignette-color-use-theme"), equals: .string(ColorUseTheme.none.rawValue))
            } catch {
                XCTFail("Failed to add Snow because of error: \(error)")
            }

            // Remove the Snow
            do {
                try mapView.mapboxMap.removeSnow()
                successfullyRemovedObjectExpectation.fulfill()
            } catch {
                XCTFail("Failed to remove Snow because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedObjectExpectation, successfullyRemovedObjectExpectation], timeout: 5.0)
    }
}

// End of generated file
