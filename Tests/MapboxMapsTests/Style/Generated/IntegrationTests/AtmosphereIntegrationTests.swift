// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class AtmosphereIntegrationTests: MapViewIntegrationTestCase {

    internal func testAddAtmosphereToMap() throws {
        let successfullyAddedObjectExpectation = XCTestExpectation(description: "Successfully added Atmosphere to Map")
        successfullyAddedObjectExpectation.expectedFulfillmentCount = 1

        let successfullyRemovedObjectExpectation = XCTestExpectation(description: "Successfully removed Atmosphere")
        successfullyRemovedObjectExpectation.expectedFulfillmentCount = 1

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
                assertCoreStoredStyleProperty("color", stored: mapView.mapboxMap.atmosphereProperty("color"), equals: .color(StyleColor.testConstantValue()))
                assertCoreStoredStyleProperty("color-transition", stored: mapView.mapboxMap.atmosphereProperty("color-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("color-use-theme", stored: mapView.mapboxMap.atmosphereProperty("color-use-theme"), equals: .string(ColorUseTheme.none.rawValue))
                assertCoreStoredStyleProperty("high-color", stored: mapView.mapboxMap.atmosphereProperty("high-color"), equals: .color(StyleColor.testConstantValue()))
                assertCoreStoredStyleProperty("high-color-transition", stored: mapView.mapboxMap.atmosphereProperty("high-color-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("high-color-use-theme", stored: mapView.mapboxMap.atmosphereProperty("high-color-use-theme"), equals: .string(ColorUseTheme.none.rawValue))
                assertCoreStoredStyleProperty("horizon-blend", stored: mapView.mapboxMap.atmosphereProperty("horizon-blend"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("horizon-blend-transition", stored: mapView.mapboxMap.atmosphereProperty("horizon-blend-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("range", stored: mapView.mapboxMap.atmosphereProperty("range"), equals: .array([0, 1]))
                assertCoreStoredStyleProperty("range-transition", stored: mapView.mapboxMap.atmosphereProperty("range-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("space-color", stored: mapView.mapboxMap.atmosphereProperty("space-color"), equals: .color(StyleColor.testConstantValue()))
                assertCoreStoredStyleProperty("space-color-transition", stored: mapView.mapboxMap.atmosphereProperty("space-color-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("space-color-use-theme", stored: mapView.mapboxMap.atmosphereProperty("space-color-use-theme"), equals: .string(ColorUseTheme.none.rawValue))
                assertCoreStoredStyleProperty("star-intensity", stored: mapView.mapboxMap.atmosphereProperty("star-intensity"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("star-intensity-transition", stored: mapView.mapboxMap.atmosphereProperty("star-intensity-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("vertical-range", stored: mapView.mapboxMap.atmosphereProperty("vertical-range"), equals: .array([0, 1]))
                assertCoreStoredStyleProperty("vertical-range-transition", stored: mapView.mapboxMap.atmosphereProperty("vertical-range-transition"), equals: .transition(.testConstantValue()))
            } catch {
                XCTFail("Failed to add Atmosphere because of error: \(error)")
            }

            // Remove the Atmosphere
            do {
                try mapView.mapboxMap.removeAtmosphere()
                successfullyRemovedObjectExpectation.fulfill()
            } catch {
                XCTFail("Failed to remove Atmosphere because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedObjectExpectation, successfullyRemovedObjectExpectation], timeout: 5.0)
    }
}

// End of generated file
