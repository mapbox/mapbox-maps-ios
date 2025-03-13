// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class FillExtrusionLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added FillExtrusionLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved FillExtrusionLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleJSON = .testStyleJSON()

        didFinishLoadingStyle = { mapView in

            var layer = FillExtrusionLayer(id: "test-id", source: "source")
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)
            layer.fillExtrusionEdgeRadius = Value<Double>.testConstantValue()
            layer.fillExtrusionAmbientOcclusionGroundAttenuation = Value<Double>.testConstantValue()
            layer.fillExtrusionAmbientOcclusionGroundAttenuationTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionAmbientOcclusionGroundRadius = Value<Double>.testConstantValue()
            layer.fillExtrusionAmbientOcclusionGroundRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionAmbientOcclusionIntensity = Value<Double>.testConstantValue()
            layer.fillExtrusionAmbientOcclusionIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionAmbientOcclusionRadius = Value<Double>.testConstantValue()
            layer.fillExtrusionAmbientOcclusionRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionAmbientOcclusionWallRadius = Value<Double>.testConstantValue()
            layer.fillExtrusionAmbientOcclusionWallRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionBase = Value<Double>.testConstantValue()
            layer.fillExtrusionBaseTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionBaseAlignment = Value<FillExtrusionBaseAlignment>.testConstantValue()
            layer.fillExtrusionColor = Value<StyleColor>.testConstantValue()
            layer.fillExtrusionColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionColorUseTheme = .testConstantValue()
            layer.fillExtrusionCutoffFadeRange = Value<Double>.testConstantValue()
            layer.fillExtrusionEmissiveStrength = Value<Double>.testConstantValue()
            layer.fillExtrusionEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionFloodLightColor = Value<StyleColor>.testConstantValue()
            layer.fillExtrusionFloodLightColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionFloodLightColorUseTheme = .testConstantValue()
            layer.fillExtrusionFloodLightGroundAttenuation = Value<Double>.testConstantValue()
            layer.fillExtrusionFloodLightGroundAttenuationTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionFloodLightGroundRadius = Value<Double>.testConstantValue()
            layer.fillExtrusionFloodLightGroundRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionFloodLightIntensity = Value<Double>.testConstantValue()
            layer.fillExtrusionFloodLightIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionFloodLightWallRadius = Value<Double>.testConstantValue()
            layer.fillExtrusionFloodLightWallRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionHeight = Value<Double>.testConstantValue()
            layer.fillExtrusionHeightTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionHeightAlignment = Value<FillExtrusionHeightAlignment>.testConstantValue()
            layer.fillExtrusionLineWidth = Value<Double>.testConstantValue()
            layer.fillExtrusionLineWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionOpacity = Value<Double>.testConstantValue()
            layer.fillExtrusionOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionPattern = Value<ResolvedImage>.testConstantValue()
            layer.fillExtrusionRoundedRoof = Value<Bool>.testConstantValue()
            layer.fillExtrusionTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.fillExtrusionTranslateAnchor = Value<FillExtrusionTranslateAnchor>.testConstantValue()
            layer.fillExtrusionVerticalGradient = Value<Bool>.testConstantValue()
            layer.fillExtrusionVerticalScale = Value<Double>.testConstantValue()
            layer.fillExtrusionVerticalScaleTransition = StyleTransition(duration: 10.0, delay: 10.0)

            // Add the layer
            do {
                try mapView.mapboxMap.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add FillExtrusionLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try mapView.mapboxMap.layer(withId: "test-id", type: FillExtrusionLayer.self)
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve FillExtrusionLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
