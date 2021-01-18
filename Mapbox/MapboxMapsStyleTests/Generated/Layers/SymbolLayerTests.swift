// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class SymbolLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

       var layer = SymbolLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       XCTAssert(layer.id == "test-id")
       XCTAssert(layer.type == LayerType.symbol)
       XCTAssert(layer.filter == nil)
       XCTAssert(layer.source == "some-source")
       XCTAssertNil(layer.sourceLayer)
       XCTAssert(layer.minZoom == 10.0)
       XCTAssert(layer.maxZoom == 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
       var layer = SymbolLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode SymbolLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode SymbolLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(SymbolLayer.self, from: validData)
           XCTAssert(decodedLayer.id == "test-id")
       	   XCTAssert(decodedLayer.type == LayerType.symbol)
           XCTAssert(decodedLayer.filter == nil)
           XCTAssert(decodedLayer.source == "some-source")
           XCTAssertNil(decodedLayer.sourceLayer)
           XCTAssert(decodedLayer.minZoom == 10.0)
           XCTAssert(decodedLayer.maxZoom == 20.0)
       } catch {
           XCTFail("Failed to decode SymbolLayer")
       }
    }

    func testEncodingAndDecodingOfLayoutProperties() {

       var layer = SymbolLayer(id: "test-id")	
       layer.layout?.visibility = .visible
       layer.layout?.iconAllowOverlap = Value<Bool>.testConstantValue()
       layer.layout?.iconAnchor = IconAnchor.testConstantValue()
       layer.layout?.iconIgnorePlacement = Value<Bool>.testConstantValue()
       layer.layout?.iconImage = Value<ResolvedImage>.testConstantValue()
       layer.layout?.iconKeepUpright = Value<Bool>.testConstantValue()
       layer.layout?.iconOffset = Value<[Double]>.testConstantValue()
       layer.layout?.iconOptional = Value<Bool>.testConstantValue()
       layer.layout?.iconPadding = Value<Double>.testConstantValue()
       layer.layout?.iconPitchAlignment = IconPitchAlignment.testConstantValue()
       layer.layout?.iconRotate = Value<Double>.testConstantValue()
       layer.layout?.iconRotationAlignment = IconRotationAlignment.testConstantValue()
       layer.layout?.iconSize = Value<Double>.testConstantValue()
       layer.layout?.iconTextFit = IconTextFit.testConstantValue()
       layer.layout?.iconTextFitPadding = Value<[Double]>.testConstantValue()
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
       layer.layout?.textOffset = Value<[Double]>.testConstantValue()
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

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode SymbolLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode SymbolLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(SymbolLayer.self, from: validData)
           XCTAssert(decodedLayer.layout?.visibility == .visible)
       	   XCTAssert(layer.layout?.iconAllowOverlap == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.layout?.iconAnchor == IconAnchor.testConstantValue())
       	   XCTAssert(layer.layout?.iconIgnorePlacement == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.layout?.iconImage == Value<ResolvedImage>.testConstantValue())
       	   XCTAssert(layer.layout?.iconKeepUpright == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.layout?.iconOffset == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.layout?.iconOptional == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.layout?.iconPadding == Value<Double>.testConstantValue())
       	   XCTAssert(layer.layout?.iconPitchAlignment == IconPitchAlignment.testConstantValue())
       	   XCTAssert(layer.layout?.iconRotate == Value<Double>.testConstantValue())
       	   XCTAssert(layer.layout?.iconRotationAlignment == IconRotationAlignment.testConstantValue())
       	   XCTAssert(layer.layout?.iconSize == Value<Double>.testConstantValue())
       	   XCTAssert(layer.layout?.iconTextFit == IconTextFit.testConstantValue())
       	   XCTAssert(layer.layout?.iconTextFitPadding == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.layout?.symbolAvoidEdges == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.layout?.symbolPlacement == SymbolPlacement.testConstantValue())
       	   XCTAssert(layer.layout?.symbolSortKey == Value<Double>.testConstantValue())
       	   XCTAssert(layer.layout?.symbolSpacing == Value<Double>.testConstantValue())
       	   XCTAssert(layer.layout?.symbolZOrder == SymbolZOrder.testConstantValue())
       	   XCTAssert(layer.layout?.textAllowOverlap == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.layout?.textAnchor == TextAnchor.testConstantValue())
       	   XCTAssert(layer.layout?.textField == Value<String>.testConstantValue())
       	   XCTAssert(layer.layout?.textFont == Value<[String]>.testConstantValue())
       	   XCTAssert(layer.layout?.textIgnorePlacement == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.layout?.textJustify == TextJustify.testConstantValue())
       	   XCTAssert(layer.layout?.textKeepUpright == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.layout?.textLetterSpacing == Value<Double>.testConstantValue())
       	   XCTAssert(layer.layout?.textLineHeight == Value<Double>.testConstantValue())
       	   XCTAssert(layer.layout?.textMaxAngle == Value<Double>.testConstantValue())
       	   XCTAssert(layer.layout?.textMaxWidth == Value<Double>.testConstantValue())
       	   XCTAssert(layer.layout?.textOffset == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.layout?.textOptional == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.layout?.textPadding == Value<Double>.testConstantValue())
       	   XCTAssert(layer.layout?.textPitchAlignment == TextPitchAlignment.testConstantValue())
       	   XCTAssert(layer.layout?.textRadialOffset == Value<Double>.testConstantValue())
       	   XCTAssert(layer.layout?.textRotate == Value<Double>.testConstantValue())
       	   XCTAssert(layer.layout?.textRotationAlignment == TextRotationAlignment.testConstantValue())
       	   XCTAssert(layer.layout?.textSize == Value<Double>.testConstantValue())
       	   XCTAssert(layer.layout?.textTransform == TextTransform.testConstantValue())
       	   XCTAssert(layer.layout?.textVariableAnchor == [TextAnchor].testConstantValue())
       	   XCTAssert(layer.layout?.textWritingMode == [TextWritingMode].testConstantValue())
 
       } catch {
           XCTFail("Failed to decode SymbolLayer")
       }
    }

    func testEncodingAndDecodingOfPaintProperties() {

       var layer = SymbolLayer(id: "test-id")	
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
       layer.paint?.iconTranslate = Value<[Double]>.testConstantValue()
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
       layer.paint?.textTranslate = Value<[Double]>.testConstantValue()
       layer.paint?.textTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.textTranslateAnchor = TextTranslateAnchor.testConstantValue()

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode SymbolLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode SymbolLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(SymbolLayer.self, from: validData)
           XCTAssert(decodedLayer.layout?.visibility == .visible)
       	   XCTAssert(layer.paint?.iconColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.paint?.iconHaloBlur == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.iconHaloColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.paint?.iconHaloWidth == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.iconOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.iconTranslate == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.paint?.iconTranslateAnchor == IconTranslateAnchor.testConstantValue())
       	   XCTAssert(layer.paint?.textColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.paint?.textHaloBlur == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.textHaloColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.paint?.textHaloWidth == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.textOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.textTranslate == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.paint?.textTranslateAnchor == TextTranslateAnchor.testConstantValue())
 
       } catch {
           XCTFail("Failed to decode SymbolLayer")
       }
    }
}

// End of generated file