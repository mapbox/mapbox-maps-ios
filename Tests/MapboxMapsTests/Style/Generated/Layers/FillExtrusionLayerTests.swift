// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class FillExtrusionLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

       var layer = FillExtrusionLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       XCTAssert(layer.id == "test-id")
       XCTAssert(layer.type == LayerType.fillExtrusion)
       XCTAssert(layer.filter == nil)
       XCTAssert(layer.source == "some-source")
       XCTAssertNil(layer.sourceLayer)
       XCTAssert(layer.minZoom == 10.0)
       XCTAssert(layer.maxZoom == 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
       var layer = FillExtrusionLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode FillExtrusionLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode FillExtrusionLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(FillExtrusionLayer.self, from: validData)
           XCTAssert(decodedLayer.id == "test-id")
       	   XCTAssert(decodedLayer.type == LayerType.fillExtrusion)
           XCTAssert(decodedLayer.filter == nil)
           XCTAssert(decodedLayer.source == "some-source")
           XCTAssertNil(decodedLayer.sourceLayer)
           XCTAssert(decodedLayer.minZoom == 10.0)
           XCTAssert(decodedLayer.maxZoom == 20.0)
       } catch {
           XCTFail("Failed to decode FillExtrusionLayer")
       }
    }

    func testEncodingAndDecodingOfLayoutProperties() {

       var layer = FillExtrusionLayer(id: "test-id")	
       layer.layout?.visibility = .visible

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode FillExtrusionLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode FillExtrusionLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(FillExtrusionLayer.self, from: validData)
           XCTAssert(decodedLayer.layout?.visibility == .visible)
 
       } catch {
           XCTFail("Failed to decode FillExtrusionLayer")
       }
    }

    func testEncodingAndDecodingOfPaintProperties() {

       var layer = FillExtrusionLayer(id: "test-id")	
       layer.paint?.fillExtrusionBase = Value<Double>.testConstantValue()
       layer.paint?.fillExtrusionBaseTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.fillExtrusionColor = Value<ColorRepresentable>.testConstantValue()
       layer.paint?.fillExtrusionColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.fillExtrusionHeight = Value<Double>.testConstantValue()
       layer.paint?.fillExtrusionHeightTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.fillExtrusionOpacity = Value<Double>.testConstantValue()
       layer.paint?.fillExtrusionOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.fillExtrusionPattern = Value<ResolvedImage>.testConstantValue()
       layer.paint?.fillExtrusionPatternTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.fillExtrusionTranslate = Value<[Double]>.testConstantValue()
       layer.paint?.fillExtrusionTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.fillExtrusionTranslateAnchor = FillExtrusionTranslateAnchor.testConstantValue()
       layer.paint?.fillExtrusionVerticalGradient = Value<Bool>.testConstantValue()

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode FillExtrusionLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode FillExtrusionLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(FillExtrusionLayer.self, from: validData)
           XCTAssert(decodedLayer.layout?.visibility == .visible)
       	   XCTAssert(layer.paint?.fillExtrusionBase == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.fillExtrusionColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.paint?.fillExtrusionHeight == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.fillExtrusionOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.fillExtrusionPattern == Value<ResolvedImage>.testConstantValue())
       	   XCTAssert(layer.paint?.fillExtrusionTranslate == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.paint?.fillExtrusionTranslateAnchor == FillExtrusionTranslateAnchor.testConstantValue())
       	   XCTAssert(layer.paint?.fillExtrusionVerticalGradient == Value<Bool>.testConstantValue())
 
       } catch {
           XCTFail("Failed to decode FillExtrusionLayer")
       }
    }
}

// End of generated file