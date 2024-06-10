// This file is generated
import XCTest
@testable import MapboxMaps

final class HillshadeLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added HillshadeLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved HillshadeLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in

            var layer = HillshadeLayer(id: "test-id", source: "source")
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)
            layer.hillshadeAccentColor = Value<StyleColor>.testConstantValue()
            layer.hillshadeAccentColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.hillshadeEmissiveStrength = Value<Double>.testConstantValue()
            layer.hillshadeEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.hillshadeExaggeration = Value<Double>.testConstantValue()
            layer.hillshadeExaggerationTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.hillshadeHighlightColor = Value<StyleColor>.testConstantValue()
            layer.hillshadeHighlightColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.hillshadeIlluminationAnchor = Value<HillshadeIlluminationAnchor>.testConstantValue()
            layer.hillshadeIlluminationDirection = Value<Double>.testConstantValue()
            layer.hillshadeShadowColor = Value<StyleColor>.testConstantValue()
            layer.hillshadeShadowColorTransition = StyleTransition(duration: 10.0, delay: 10.0)

            // Add the layer
            do {
                try mapView.mapboxMap.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add HillshadeLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try mapView.mapboxMap.layer(withId: "test-id", type: HillshadeLayer.self)
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve HillshadeLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
