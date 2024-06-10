// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class ModelLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added ModelLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved ModelLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in

            var layer = ModelLayer(id: "test-id", source: "source")
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)
            layer.modelId = Value<String>.testConstantValue()
            layer.modelAmbientOcclusionIntensity = Value<Double>.testConstantValue()
            layer.modelAmbientOcclusionIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.modelCastShadows = Value<Bool>.testConstantValue()
            layer.modelColor = Value<StyleColor>.testConstantValue()
            layer.modelColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.modelColorMixIntensity = Value<Double>.testConstantValue()
            layer.modelColorMixIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.modelCutoffFadeRange = Value<Double>.testConstantValue()
            layer.modelEmissiveStrength = Value<Double>.testConstantValue()
            layer.modelEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.modelHeightBasedEmissiveStrengthMultiplierTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.modelOpacity = Value<Double>.testConstantValue()
            layer.modelOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.modelReceiveShadows = Value<Bool>.testConstantValue()
            layer.modelRotationTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.modelRoughness = Value<Double>.testConstantValue()
            layer.modelRoughnessTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.modelScaleTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.modelScaleMode = Value<ModelScaleMode>.testConstantValue()
            layer.modelTranslationTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.modelType = Value<ModelType>.testConstantValue()

            // Add the layer
            do {
                try mapView.mapboxMap.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add ModelLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try mapView.mapboxMap.layer(withId: "test-id", type: ModelLayer.self)
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve ModelLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
