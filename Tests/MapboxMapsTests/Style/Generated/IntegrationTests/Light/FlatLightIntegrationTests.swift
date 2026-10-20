// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class FlatLightIntegrationTests: MapViewIntegrationTestCase {

    internal func testAddFlatLightToMap() throws {
        let successfullyAddedObjectExpectation = XCTestExpectation(description: "Successfully added FlatLight to Map")
        successfullyAddedObjectExpectation.expectedFulfillmentCount = 1

        let successfullyRemovedObjectExpectation = XCTestExpectation(description: "Successfully removed FlatLight")
        successfullyRemovedObjectExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleJSON = .testStyleJSON()

        didFinishLoadingStyle = { mapView in

            let instance = FlatLight()
                .anchor(Anchor.testConstantValue())
                .color(StyleColor.testConstantValue())
                .colorTransition(.testConstantValue())
                .colorUseTheme(.none)
                .intensity(Double.testConstantValue())
                .intensityTransition(.testConstantValue())
                .position(radial: 0, azimuthal: 1, polar: 2)
                .positionTransition(.testConstantValue())

            // Add the FlatLight
            do {
                try mapView.mapboxMap.setLights(instance)
                successfullyAddedObjectExpectation.fulfill()
                assertCoreStoredStyleProperty("anchor", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "anchor"), equals: .string(Anchor.testConstantValue().rawValue))
                assertCoreStoredStyleProperty("color", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "color"), equals: .color(StyleColor.testConstantValue()))
                assertCoreStoredStyleProperty("color-transition", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "color-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("color-use-theme", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "color-use-theme"), equals: .string(ColorUseTheme.none.rawValue))
                assertCoreStoredStyleProperty("intensity", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "intensity"), equals: .number(Double.testConstantValue()))
                assertCoreStoredStyleProperty("intensity-transition", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "intensity-transition"), equals: .transition(.testConstantValue()))
                assertCoreStoredStyleProperty("position", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "position"), equals: .array([0, 1, 2]))
                assertCoreStoredStyleProperty("position-transition", stored: mapView.mapboxMap.lightPropertyValue(for: instance.id, property: "position-transition"), equals: .transition(.testConstantValue()))
            } catch {
                XCTFail("Failed to add FlatLight because of error: \(error)")
            }

            // Remove the FlatLight
            do {
                try mapView.mapboxMap.resetLights()
                successfullyRemovedObjectExpectation.fulfill()
            } catch {
                XCTFail("Failed to remove FlatLight because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedObjectExpectation, successfullyRemovedObjectExpectation], timeout: 5.0)
    }
}

// End of generated file
