// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class DirectionalLightIntegrationTests: MapViewIntegrationTestCase {

    internal func testAddDirectionalLightToMap() throws {
        let successfullyAddedObjectExpectation = XCTestExpectation(description: "Successfully added DirectionalLight to Map")
        successfullyAddedObjectExpectation.expectedFulfillmentCount = 1

        let successfullyRemovedObjectExpectation = XCTestExpectation(description: "Successfully removed DirectionalLight")
        successfullyRemovedObjectExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleJSON = .testStyleJSON()

        didFinishLoadingStyle = { mapView in

            let instance = DirectionalLight()
                .castShadows(Bool.testConstantValue())
                .color(StyleColor.testConstantValue())
                .colorTransition(.testConstantValue())
                .colorUseTheme(.none)
                .direction(azimuthal: 0, polar: 1)
                .directionTransition(.testConstantValue())
                .intensity(Double.testConstantValue())
                .intensityTransition(.testConstantValue())
                .shadowDrawBeforeLayer(String.testConstantValue())
                .shadowIntensity(Double.testConstantValue())
                .shadowIntensityTransition(.testConstantValue())

            // Add the DirectionalLight
            do {
                try mapView.mapboxMap.setLights(ambient: AmbientLight(), directional: instance)
                successfullyAddedObjectExpectation.fulfill()
                assertCoreStoredStyleProperty("cast-shadows", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "cast-shadows"), equals: .boolean(Bool.testConstantValue()))
                assertCoreStoredStyleProperty("color", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "color"), equals: .color(StyleColor.testConstantValue()))
                assertCoreStoredStyleProperty("color-transition", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "color-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("color-use-theme", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "color-use-theme"), equals: .string(ColorUseTheme.none.rawValue))
                assertCoreStoredStyleProperty("direction", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "direction"), equals: .array([0, 1]))
                assertCoreStoredStyleProperty("direction-transition", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "direction-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("intensity", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "intensity"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("intensity-transition", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "intensity-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("shadow-draw-before-layer", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "shadow-draw-before-layer"), equals: .string(String.testConstantValue()))
                assertCoreStoredStyleProperty("shadow-intensity", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "shadow-intensity"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("shadow-intensity-transition", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "shadow-intensity-transition"), equals: .transition(.testConstantValue()))
            } catch {
                XCTFail("Failed to add DirectionalLight because of error: \(error)")
            }

            // Remove the DirectionalLight
            do {
                try mapView.mapboxMap.resetLights()
                successfullyRemovedObjectExpectation.fulfill()
            } catch {
                XCTFail("Failed to remove DirectionalLight because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedObjectExpectation, successfullyRemovedObjectExpectation], timeout: 5.0)
    }
}

// End of generated file
