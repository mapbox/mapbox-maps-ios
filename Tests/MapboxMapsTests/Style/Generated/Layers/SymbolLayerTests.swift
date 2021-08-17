// This file is generated
import XCTest
@testable import MapboxMaps

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
       layer.visibility = .constant(.visible)
       layer.iconAllowOverlap = Value<Bool>.testConstantValue()
       layer.iconAnchor = Value<IconAnchor>.testConstantValue()
       layer.iconIgnorePlacement = Value<Bool>.testConstantValue()
       layer.iconImage = Value<ResolvedImage>.testConstantValue()
       layer.iconKeepUpright = Value<Bool>.testConstantValue()
       layer.iconOffset = Value<[Double]>.testConstantValue()
       layer.iconOptional = Value<Bool>.testConstantValue()
       layer.iconPadding = Value<Double>.testConstantValue()
       layer.iconPitchAlignment = Value<IconPitchAlignment>.testConstantValue()
       layer.iconRotate = Value<Double>.testConstantValue()
       layer.iconRotationAlignment = Value<IconRotationAlignment>.testConstantValue()
       layer.iconSize = Value<Double>.testConstantValue()
       layer.iconTextFit = Value<IconTextFit>.testConstantValue()
       layer.iconTextFitPadding = Value<[Double]>.testConstantValue()
       layer.symbolAvoidEdges = Value<Bool>.testConstantValue()
       layer.symbolPlacement = Value<SymbolPlacement>.testConstantValue()
       layer.symbolSortKey = Value<Double>.testConstantValue()
       layer.symbolSpacing = Value<Double>.testConstantValue()
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
       layer.textOffset = Value<[Double]>.testConstantValue()
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
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       	   XCTAssert(layer.iconAllowOverlap == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.iconAnchor == Value<IconAnchor>.testConstantValue())
       	   XCTAssert(layer.iconIgnorePlacement == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.iconImage == Value<ResolvedImage>.testConstantValue())
       	   XCTAssert(layer.iconKeepUpright == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.iconOffset == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.iconOptional == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.iconPadding == Value<Double>.testConstantValue())
       	   XCTAssert(layer.iconPitchAlignment == Value<IconPitchAlignment>.testConstantValue())
       	   XCTAssert(layer.iconRotate == Value<Double>.testConstantValue())
       	   XCTAssert(layer.iconRotationAlignment == Value<IconRotationAlignment>.testConstantValue())
       	   XCTAssert(layer.iconSize == Value<Double>.testConstantValue())
       	   XCTAssert(layer.iconTextFit == Value<IconTextFit>.testConstantValue())
       	   XCTAssert(layer.iconTextFitPadding == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.symbolAvoidEdges == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.symbolPlacement == Value<SymbolPlacement>.testConstantValue())
       	   XCTAssert(layer.symbolSortKey == Value<Double>.testConstantValue())
       	   XCTAssert(layer.symbolSpacing == Value<Double>.testConstantValue())
       	   XCTAssert(layer.symbolZOrder == Value<SymbolZOrder>.testConstantValue())
       	   XCTAssert(layer.textAllowOverlap == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.textAnchor == Value<TextAnchor>.testConstantValue())
       	   XCTAssert(layer.textField == Value<String>.testConstantValue())
       	   XCTAssert(layer.textFont == Value<[String]>.testConstantValue())
       	   XCTAssert(layer.textIgnorePlacement == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.textJustify == Value<TextJustify>.testConstantValue())
       	   XCTAssert(layer.textKeepUpright == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.textLetterSpacing == Value<Double>.testConstantValue())
       	   XCTAssert(layer.textLineHeight == Value<Double>.testConstantValue())
       	   XCTAssert(layer.textMaxAngle == Value<Double>.testConstantValue())
       	   XCTAssert(layer.textMaxWidth == Value<Double>.testConstantValue())
       	   XCTAssert(layer.textOffset == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.textOptional == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.textPadding == Value<Double>.testConstantValue())
       	   XCTAssert(layer.textPitchAlignment == Value<TextPitchAlignment>.testConstantValue())
       	   XCTAssert(layer.textRadialOffset == Value<Double>.testConstantValue())
       	   XCTAssert(layer.textRotate == Value<Double>.testConstantValue())
       	   XCTAssert(layer.textRotationAlignment == Value<TextRotationAlignment>.testConstantValue())
       	   XCTAssert(layer.textSize == Value<Double>.testConstantValue())
       	   XCTAssert(layer.textTransform == Value<TextTransform>.testConstantValue())
       	   XCTAssert(layer.textVariableAnchor == Value<[TextAnchor]>.testConstantValue())
       	   XCTAssert(layer.textWritingMode == Value<[TextWritingMode]>.testConstantValue())
       } catch {
           XCTFail("Failed to decode SymbolLayer")
       }
    }

    func testEncodingAndDecodingOfPaintProperties() {

       var layer = SymbolLayer(id: "test-id")
       layer.iconColor = Value<ColorRepresentable>.testConstantValue()
       layer.iconColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.iconHaloBlur = Value<Double>.testConstantValue()
       layer.iconHaloBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.iconHaloColor = Value<ColorRepresentable>.testConstantValue()
       layer.iconHaloColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.iconHaloWidth = Value<Double>.testConstantValue()
       layer.iconHaloWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.iconOpacity = Value<Double>.testConstantValue()
       layer.iconOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.iconTranslate = Value<[Double]>.testConstantValue()
       layer.iconTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.iconTranslateAnchor = Value<IconTranslateAnchor>.testConstantValue()
       layer.textColor = Value<ColorRepresentable>.testConstantValue()
       layer.textColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.textHaloBlur = Value<Double>.testConstantValue()
       layer.textHaloBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.textHaloColor = Value<ColorRepresentable>.testConstantValue()
       layer.textHaloColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.textHaloWidth = Value<Double>.testConstantValue()
       layer.textHaloWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.textOpacity = Value<Double>.testConstantValue()
       layer.textOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.textTranslate = Value<[Double]>.testConstantValue()
       layer.textTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.textTranslateAnchor = Value<TextTranslateAnchor>.testConstantValue()

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
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       	   XCTAssert(layer.iconColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.iconHaloBlur == Value<Double>.testConstantValue())
       	   XCTAssert(layer.iconHaloColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.iconHaloWidth == Value<Double>.testConstantValue())
       	   XCTAssert(layer.iconOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.iconTranslate == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.iconTranslateAnchor == Value<IconTranslateAnchor>.testConstantValue())
       	   XCTAssert(layer.textColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.textHaloBlur == Value<Double>.testConstantValue())
       	   XCTAssert(layer.textHaloColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.textHaloWidth == Value<Double>.testConstantValue())
       	   XCTAssert(layer.textOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.textTranslate == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.textTranslateAnchor == Value<TextTranslateAnchor>.testConstantValue())
       } catch {
           XCTFail("Failed to decode SymbolLayer")
       }
    }
}

// End of generated file
