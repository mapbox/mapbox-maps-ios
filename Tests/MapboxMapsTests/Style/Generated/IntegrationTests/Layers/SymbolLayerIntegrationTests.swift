// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class SymbolLayerIntegrationTests: MapViewIntegrationTestCase {

    internal func testBaseClass() throws {
        // Do nothing
    }

    internal func testWaitForIdle() throws {
        guard let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let successfullyAddedLayerExpectation = XCTestExpectation(description: "Successfully added SymbolLayer to Map")
        successfullyAddedLayerExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedLayerExpectation = XCTestExpectation(description: "Successfully retrieved SymbolLayer from Map")
        successfullyRetrievedLayerExpectation.expectedFulfillmentCount = 1

        style.styleURI = .streets

        didFinishLoadingStyle = { _ in

            var layer = SymbolLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .constant(.visible)
            layer.layout?.iconAllowOverlap = Value<Bool>.testConstantValue()
            layer.layout?.iconAnchor = Value<IconAnchor>.testConstantValue()
            layer.layout?.iconIgnorePlacement = Value<Bool>.testConstantValue()
            layer.layout?.iconImage = Value<ResolvedImage>.testConstantValue()
            layer.layout?.iconKeepUpright = Value<Bool>.testConstantValue()
            layer.layout?.iconOptional = Value<Bool>.testConstantValue()
            layer.layout?.iconPadding = Value<Double>.testConstantValue()
            layer.layout?.iconPitchAlignment = Value<IconPitchAlignment>.testConstantValue()
            layer.layout?.iconRotate = Value<Double>.testConstantValue()
            layer.layout?.iconRotationAlignment = Value<IconRotationAlignment>.testConstantValue()
            layer.layout?.iconSize = Value<Double>.testConstantValue()
            layer.layout?.iconTextFit = Value<IconTextFit>.testConstantValue()
            layer.layout?.symbolAvoidEdges = Value<Bool>.testConstantValue()
            layer.layout?.symbolPlacement = Value<SymbolPlacement>.testConstantValue()
            layer.layout?.symbolSortKey = Value<Double>.testConstantValue()
            layer.layout?.symbolSpacing = Value<Double>.testConstantValue()
            layer.layout?.symbolZOrder = Value<SymbolZOrder>.testConstantValue()
            layer.layout?.textAllowOverlap = Value<Bool>.testConstantValue()
            layer.layout?.textAnchor = Value<TextAnchor>.testConstantValue()
            layer.layout?.textField = Value<Formatted>.testConstantValue()
            layer.layout?.textFont = Value<[String]>.testConstantValue()
            layer.layout?.textIgnorePlacement = Value<Bool>.testConstantValue()
            layer.layout?.textJustify = Value<TextJustify>.testConstantValue()
            layer.layout?.textKeepUpright = Value<Bool>.testConstantValue()
            layer.layout?.textLetterSpacing = Value<Double>.testConstantValue()
            layer.layout?.textLineHeight = Value<Double>.testConstantValue()
            layer.layout?.textMaxAngle = Value<Double>.testConstantValue()
            layer.layout?.textMaxWidth = Value<Double>.testConstantValue()
            layer.layout?.textOptional = Value<Bool>.testConstantValue()
            layer.layout?.textPadding = Value<Double>.testConstantValue()
            layer.layout?.textPitchAlignment = Value<TextPitchAlignment>.testConstantValue()
            layer.layout?.textRadialOffset = Value<Double>.testConstantValue()
            layer.layout?.textRotate = Value<Double>.testConstantValue()
            layer.layout?.textRotationAlignment = Value<TextRotationAlignment>.testConstantValue()
            layer.layout?.textSize = Value<Double>.testConstantValue()
            layer.layout?.textTransform = Value<TextTransform>.testConstantValue()
            layer.layout?.textVariableAnchor = Value<[TextAnchor]>.testConstantValue()
            layer.layout?.textWritingMode = Value<[TextWritingMode]>.testConstantValue()

            layer.paint?.iconColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.iconColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.iconHaloBlur = Value<Double>.testConstantValue()
            layer.paint?.iconHaloBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.iconHaloColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.iconHaloColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.iconHaloWidth = Value<Double>.testConstantValue()
            layer.paint?.iconHaloWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.iconOpacity = Value<Double>.testConstantValue()
            layer.paint?.iconOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.iconTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.iconTranslateAnchor = Value<IconTranslateAnchor>.testConstantValue()
            layer.paint?.textColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.textColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.textHaloBlur = Value<Double>.testConstantValue()
            layer.paint?.textHaloBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.textHaloColor = Value<ColorRepresentable>.testConstantValue()
            layer.paint?.textHaloColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.textHaloWidth = Value<Double>.testConstantValue()
            layer.paint?.textHaloWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.textOpacity = Value<Double>.testConstantValue()
            layer.paint?.textOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.textTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
            layer.paint?.textTranslateAnchor = Value<TextTranslateAnchor>.testConstantValue()

            // Add the layer
            let addResult = style.addLayer(layer: layer)

            switch (addResult) {
                case .success(_):
                    successfullyAddedLayerExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to add SymbolLayer because of error: \(error)")
            }

            // Retrieve the layer
            let retrieveResult = style.getLayer(with: "test-id", type: SymbolLayer.self)

            switch (retrieveResult) {
                case .success(_):
                    successfullyRetrievedLayerExpectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to retreive SymbolLayer because of error: \(error)")   
            }
        }

        wait(for: [successfullyAddedLayerExpectation, successfullyRetrievedLayerExpectation], timeout: 5.0)
    }
}

// End of generated file