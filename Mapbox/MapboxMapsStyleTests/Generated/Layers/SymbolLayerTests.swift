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
}

// End of generated file