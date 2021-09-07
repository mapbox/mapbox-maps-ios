// This file is generated
import XCTest
@testable import MapboxMaps

final class FillExtrusionLayerTests: XCTestCase {

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
       layer.visibility = .constant(.visible)

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
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       } catch {
           XCTFail("Failed to decode FillExtrusionLayer")
       }
    }

    func testEncodingAndDecodingOfPaintProperties() {

       var layer = FillExtrusionLayer(id: "test-id")
       layer.fillExtrusionBase = Value<Double>.testConstantValue()
       layer.fillExtrusionBaseTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionColor = Value<StyleColor>.testConstantValue()
       layer.fillExtrusionColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionHeight = Value<Double>.testConstantValue()
       layer.fillExtrusionHeightTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionOpacity = Value<Double>.testConstantValue()
       layer.fillExtrusionOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionPattern = Value<ResolvedImage>.testConstantValue()
       layer.fillExtrusionPatternTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionTranslate = Value<[Double]>.testConstantValue()
       layer.fillExtrusionTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionTranslateAnchor = Value<FillExtrusionTranslateAnchor>.testConstantValue()
       layer.fillExtrusionVerticalGradient = Value<Bool>.testConstantValue()

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
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       	   XCTAssert(layer.fillExtrusionBase == Value<Double>.testConstantValue())
       	   XCTAssert(layer.fillExtrusionColor == Value<StyleColor>.testConstantValue())
       	   XCTAssert(layer.fillExtrusionHeight == Value<Double>.testConstantValue())
       	   XCTAssert(layer.fillExtrusionOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.fillExtrusionPattern == Value<ResolvedImage>.testConstantValue())
       	   XCTAssert(layer.fillExtrusionTranslate == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.fillExtrusionTranslateAnchor == Value<FillExtrusionTranslateAnchor>.testConstantValue())
       	   XCTAssert(layer.fillExtrusionVerticalGradient == Value<Bool>.testConstantValue())
       } catch {
           XCTFail("Failed to decode FillExtrusionLayer")
       }
    }
}

// End of generated file
