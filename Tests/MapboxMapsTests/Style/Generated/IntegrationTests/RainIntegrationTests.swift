// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class RainIntegrationTests: MapViewIntegrationTestCase {

    internal func testAddRainToMap() throws {
        let successfullyAddedObjectExpectation = XCTestExpectation(description: "Successfully added Rain to Map")
        successfullyAddedObjectExpectation.expectedFulfillmentCount = 1

        let successfullyRemovedObjectExpectation = XCTestExpectation(description: "Successfully removed Rain")
        successfullyRemovedObjectExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleJSON = .testStyleJSON()

        didFinishLoadingStyle = { mapView in

            let instance = Rain()
                .centerThinning(Double.testConstantValue())
                .centerThinningTransition(.testConstantValue())
                .color(StyleColor.testConstantValue())
                .colorTransition(.testConstantValue())
                .colorUseTheme(.none)
                .density(Double.testConstantValue())
                .densityTransition(.testConstantValue())
                .direction(azimuthal: 0, polar: 1)
                .directionTransition(.testConstantValue())
                .distortionStrength(Double.testConstantValue())
                .distortionStrengthTransition(.testConstantValue())
                .dropletSize(normalToDirection: 0, alongDirection: 1)
                .dropletSizeTransition(.testConstantValue())
                .intensity(Double.testConstantValue())
                .intensityTransition(.testConstantValue())
                .opacity(Double.testConstantValue())
                .opacityTransition(.testConstantValue())
                .vignette(Double.testConstantValue())
                .vignetteTransition(.testConstantValue())
                .vignetteColor(StyleColor.testConstantValue())
                .vignetteColorTransition(.testConstantValue())
                .vignetteColorUseTheme(.none)

            // Add the Rain
            do {
                try mapView.mapboxMap.setRain(instance)
                successfullyAddedObjectExpectation.fulfill()
                assertCoreStoredStyleProperty("center-thinning", stored: mapView.mapboxMap.rainProperty("center-thinning"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("center-thinning-transition", stored: mapView.mapboxMap.rainProperty("center-thinning-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("color", stored: mapView.mapboxMap.rainProperty("color"), equals: .color(StyleColor.testConstantValue()))
                assertCoreStoredStyleProperty("color-transition", stored: mapView.mapboxMap.rainProperty("color-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("color-use-theme", stored: mapView.mapboxMap.rainProperty("color-use-theme"), equals: .string(ColorUseTheme.none.rawValue))
                assertCoreStoredStyleProperty("density", stored: mapView.mapboxMap.rainProperty("density"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("density-transition", stored: mapView.mapboxMap.rainProperty("density-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("direction", stored: mapView.mapboxMap.rainProperty("direction"), equals: .array([0, 1]))
                assertCoreStoredStyleProperty("direction-transition", stored: mapView.mapboxMap.rainProperty("direction-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("distortion-strength", stored: mapView.mapboxMap.rainProperty("distortion-strength"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("distortion-strength-transition", stored: mapView.mapboxMap.rainProperty("distortion-strength-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("droplet-size", stored: mapView.mapboxMap.rainProperty("droplet-size"), equals: .array([0, 1]))
                assertCoreStoredStyleProperty("droplet-size-transition", stored: mapView.mapboxMap.rainProperty("droplet-size-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("intensity", stored: mapView.mapboxMap.rainProperty("intensity"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("intensity-transition", stored: mapView.mapboxMap.rainProperty("intensity-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("opacity", stored: mapView.mapboxMap.rainProperty("opacity"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("opacity-transition", stored: mapView.mapboxMap.rainProperty("opacity-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("vignette", stored: mapView.mapboxMap.rainProperty("vignette"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("vignette-transition", stored: mapView.mapboxMap.rainProperty("vignette-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("vignette-color", stored: mapView.mapboxMap.rainProperty("vignette-color"), equals: .color(StyleColor.testConstantValue()))
                assertCoreStoredStyleProperty("vignette-color-transition", stored: mapView.mapboxMap.rainProperty("vignette-color-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("vignette-color-use-theme", stored: mapView.mapboxMap.rainProperty("vignette-color-use-theme"), equals: .string(ColorUseTheme.none.rawValue))
            } catch {
                XCTFail("Failed to add Rain because of error: \(error)")
            }

            // Remove the Rain
            do {
                try mapView.mapboxMap.removeRain()
                successfullyRemovedObjectExpectation.fulfill()
            } catch {
                XCTFail("Failed to remove Rain because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedObjectExpectation, successfullyRemovedObjectExpectation], timeout: 5.0)
    }
}

// End of generated file
