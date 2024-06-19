// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class SymbolLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added SymbolLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved SymbolLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in

            var layer = SymbolLayer(id: "test-id", source: "source")
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.visibility = .constant(.visible)
            layer.iconAllowOverlap = Value<Bool>.testConstantValue()
            layer.iconAnchor = Value<IconAnchor>.testConstantValue()
            layer.iconIgnorePlacement = Value<Bool>.testConstantValue()
            layer.iconImage = Value<ResolvedImage>.testConstantValue()
            layer.iconKeepUpright = Value<Bool>.testConstantValue()
            layer.iconOptional = Value<Bool>.testConstantValue()
            layer.iconPadding = Value<Double>.testConstantValue()
            layer.iconPitchAlignment = Value<IconPitchAlignment>.testConstantValue()
            layer.iconRotate = Value<Double>.testConstantValue()
            layer.iconRotationAlignment = Value<IconRotationAlignment>.testConstantValue()
            layer.iconSize = Value<Double>.testConstantValue()
            layer.iconTextFit = Value<IconTextFit>.testConstantValue()
            layer.symbolAvoidEdges = Value<Bool>.testConstantValue()
            layer.symbolPlacement = Value<SymbolPlacement>.testConstantValue()
            layer.symbolSortKey = Value<Double>.testConstantValue()
            layer.symbolSpacing = Value<Double>.testConstantValue()
            layer.symbolZElevate = Value<Bool>.testConstantValue()
            layer.symbolZOrder = Value<SymbolZOrder>.testConstantValue()
            layer.textAllowOverlap = Value<Bool>.testConstantValue()
            layer.textAnchor = Value<TextAnchor>.testConstantValue()
            layer.textField = Value<String>.testConstantValue()
            layer.textFont = Value<[String]>.testConstantValue()
            layer.textIgnorePlacement = Value<Bool>.testConstantValue()
            layer.textJustify = Value<TextJustify>.testConstantValue()
            layer.textKeepUpright = Value<Bool>.testConstantValue()
            layer.textLetterSpacing = Value<Double>.testConstantValue()
            layer.textLineHeight = Value<Double>.testConstantValue()
            layer.textMaxAngle = Value<Double>.testConstantValue()
            layer.textMaxWidth = Value<Double>.testConstantValue()
            layer.textOptional = Value<Bool>.testConstantValue()
            layer.textPadding = Value<Double>.testConstantValue()
            layer.textPitchAlignment = Value<TextPitchAlignment>.testConstantValue()
            layer.textRadialOffset = Value<Double>.testConstantValue()
            layer.textRotate = Value<Double>.testConstantValue()
            layer.textRotationAlignment = Value<TextRotationAlignment>.testConstantValue()
            layer.textSize = Value<Double>.testConstantValue()
            layer.textTransform = Value<TextTransform>.testConstantValue()
            layer.textVariableAnchor = Value<[TextAnchor]>.testConstantValue()
            layer.textWritingMode = Value<[TextWritingMode]>.testConstantValue()
            layer.iconColor = Value<StyleColor>.testConstantValue()
            layer.iconColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.iconColorSaturation = Value<Double>.testConstantValue()
            layer.iconColorSaturationTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.iconEmissiveStrength = Value<Double>.testConstantValue()
            layer.iconEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.iconHaloBlur = Value<Double>.testConstantValue()
            layer.iconHaloBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.iconHaloColor = Value<StyleColor>.testConstantValue()
            layer.iconHaloColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.iconHaloWidth = Value<Double>.testConstantValue()
            layer.iconHaloWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.iconImageCrossFade = Value<Double>.testConstantValue()
            layer.iconImageCrossFadeTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.iconOcclusionOpacity = Value<Double>.testConstantValue()
            layer.iconOcclusionOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.iconOpacity = Value<Double>.testConstantValue()
            layer.iconOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.iconTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.iconTranslateAnchor = Value<IconTranslateAnchor>.testConstantValue()
            layer.textColor = Value<StyleColor>.testConstantValue()
            layer.textColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.textEmissiveStrength = Value<Double>.testConstantValue()
            layer.textEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.textHaloBlur = Value<Double>.testConstantValue()
            layer.textHaloBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.textHaloColor = Value<StyleColor>.testConstantValue()
            layer.textHaloColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.textHaloWidth = Value<Double>.testConstantValue()
            layer.textHaloWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.textOcclusionOpacity = Value<Double>.testConstantValue()
            layer.textOcclusionOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.textOpacity = Value<Double>.testConstantValue()
            layer.textOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.textTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.textTranslateAnchor = Value<TextTranslateAnchor>.testConstantValue()

            // Add the layer
            do {
                try mapView.mapboxMap.addLayer(layer)
                successfullyAddedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to add SymbolLayer because of error: \(error)")
            }

            // Retrieve the layer
            do {
                _ = try mapView.mapboxMap.layer(withId: "test-id", type: SymbolLayer.self)
                successfullyRetrievedLayerExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve SymbolLayer because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file
