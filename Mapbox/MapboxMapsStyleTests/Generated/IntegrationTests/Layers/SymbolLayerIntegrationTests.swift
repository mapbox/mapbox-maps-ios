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
        guard
            let mapView = mapView,
            let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let expectation = XCTestExpectation(description: "Successfully add SymbolLayer to Map")
        expectation.expectedFulfillmentCount = 1

        style.styleURL = .streets

        didFinishLoadingStyle = { _ in

            var layer = SymbolLayer(id: "test-id")
            layer.source = "some-source"
            layer.sourceLayer = nil
            layer.minZoom = 10.0
            layer.maxZoom = 20.0
            layer.layout?.visibility = .visible
            layer.layout?.iconAllowOverlap = Value<Bool>.testConstantValue()
            layer.layout?.iconAnchor = IconAnchor.testConstantValue()
            layer.layout?.iconIgnorePlacement = Value<Bool>.testConstantValue()
            layer.layout?.iconImage = Value<ResolvedImage>.testConstantValue()
            layer.layout?.iconKeepUpright = Value<Bool>.testConstantValue()
            layer.layout?.iconOptional = Value<Bool>.testConstantValue()
            layer.layout?.iconPadding = Value<Double>.testConstantValue()
            layer.layout?.iconPitchAlignment = IconPitchAlignment.testConstantValue()
            layer.layout?.iconRotate = Value<Double>.testConstantValue()
            layer.layout?.iconRotationAlignment = IconRotationAlignment.testConstantValue()
            layer.layout?.iconSize = Value<Double>.testConstantValue()
            layer.layout?.iconTextFit = IconTextFit.testConstantValue()
            layer.layout?.symbolAvoidEdges = Value<Bool>.testConstantValue()
            layer.layout?.symbolPlacement = SymbolPlacement.testConstantValue()
            layer.layout?.symbolSortKey = Value<Double>.testConstantValue()
            layer.layout?.symbolSpacing = Value<Double>.testConstantValue()
            layer.layout?.symbolZOrder = SymbolZOrder.testConstantValue()
            layer.layout?.textAllowOverlap = Value<Bool>.testConstantValue()
            layer.layout?.textAnchor = TextAnchor.testConstantValue()
            layer.layout?.textField = Value<String>.testConstantValue()
            layer.layout?.textFont = Value<[String]>.testConstantValue()
            layer.layout?.textIgnorePlacement = Value<Bool>.testConstantValue()
            layer.layout?.textJustify = TextJustify.testConstantValue()
            layer.layout?.textKeepUpright = Value<Bool>.testConstantValue()
            layer.layout?.textLetterSpacing = Value<Double>.testConstantValue()
            layer.layout?.textLineHeight = Value<Double>.testConstantValue()
            layer.layout?.textMaxAngle = Value<Double>.testConstantValue()
            layer.layout?.textMaxWidth = Value<Double>.testConstantValue()
            layer.layout?.textOptional = Value<Bool>.testConstantValue()
            layer.layout?.textPadding = Value<Double>.testConstantValue()
            layer.layout?.textPitchAlignment = TextPitchAlignment.testConstantValue()
            layer.layout?.textRadialOffset = Value<Double>.testConstantValue()
            layer.layout?.textRotate = Value<Double>.testConstantValue()
            layer.layout?.textRotationAlignment = TextRotationAlignment.testConstantValue()
            layer.layout?.textSize = Value<Double>.testConstantValue()
            layer.layout?.textTransform = TextTransform.testConstantValue()
            layer.layout?.textVariableAnchor = [TextAnchor].testConstantValue()
            layer.layout?.textWritingMode = [TextWritingMode].testConstantValue()

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
            layer.paint?.iconTranslateAnchor = IconTranslateAnchor.testConstantValue()
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
            layer.paint?.textTranslateAnchor = TextTranslateAnchor.testConstantValue()

            let result = style.addLayer(layer: layer)

            switch (result) {
                case .success(_):
                    expectation.fulfill()    
                case .failure(let error):
                    XCTFail("Failed to add SymbolLayer because of error: \(error)")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
}

// End of generated file