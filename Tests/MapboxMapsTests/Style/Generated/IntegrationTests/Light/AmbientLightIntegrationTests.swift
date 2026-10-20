// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class AmbientLightIntegrationTests: MapViewIntegrationTestCase {

    internal func testAddAmbientLightToMap() throws {
        let successfullyAddedObjectExpectation = XCTestExpectation(description: "Successfully added AmbientLight to Map")
        successfullyAddedObjectExpectation.expectedFulfillmentCount = 1

        let successfullyRemovedObjectExpectation = XCTestExpectation(description: "Successfully removed AmbientLight")
        successfullyRemovedObjectExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleJSON = .testStyleJSON()

        didFinishLoadingStyle = { mapView in

            let instance = AmbientLight()
                .color(StyleColor.testConstantValue())
                .colorTransition(.testConstantValue())
                .colorUseTheme(.none)
                .intensity(Double.testConstantValue())
                .intensityTransition(.testConstantValue())

            // Add the AmbientLight
            do {
                try mapView.mapboxMap.setLights(ambient: instance, directional: DirectionalLight())
                successfullyAddedObjectExpectation.fulfill()
                assertCoreStoredStyleProperty("color", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "color"), equals: .color(StyleColor.testConstantValue()))
                assertCoreStoredStyleProperty("color-transition", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "color-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("color-use-theme", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "color-use-theme"), equals: .string(ColorUseTheme.none.rawValue))
                assertCoreStoredStyleProperty("intensity", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "intensity"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("intensity-transition", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "intensity-transition"), equals: .transition(.testConstantValue()))
            } catch {
                XCTFail("Failed to add AmbientLight because of error: \(error)")
            }

            // Remove the AmbientLight
            do {
                try mapView.mapboxMap.resetLights()
                successfullyRemovedObjectExpectation.fulfill()
            } catch {
                XCTFail("Failed to remove AmbientLight because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedObjectExpectation, successfullyRemovedObjectExpectation], timeout: 5.0)
    }
}

// End of generated file
