// This file is generated
import XCTest
@testable import MapboxMaps

class FillLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

       var layer = FillLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       XCTAssert(layer.id == "test-id")
       XCTAssert(layer.type == LayerType.fill)
       XCTAssert(layer.filter == nil)
       XCTAssert(layer.source == "some-source")
       XCTAssertNil(layer.sourceLayer)
       XCTAssert(layer.minZoom == 10.0)
       XCTAssert(layer.maxZoom == 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
       var layer = FillLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode FillLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode FillLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(FillLayer.self, from: validData)
           XCTAssert(decodedLayer.id == "test-id")
       	   XCTAssert(decodedLayer.type == LayerType.fill)
           XCTAssert(decodedLayer.filter == nil)
           XCTAssert(decodedLayer.source == "some-source")
           XCTAssertNil(decodedLayer.sourceLayer)
           XCTAssert(decodedLayer.minZoom == 10.0)
           XCTAssert(decodedLayer.maxZoom == 20.0)
       } catch {
           XCTFail("Failed to decode FillLayer")
       }
    }

    func testEncodingAndDecodingOfLayoutProperties() {

       var layer = FillLayer(id: "test-id")
       layer.visibility = .constant(.visible)
       layer.fillSortKey = Value<Double>.testConstantValue()

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode FillLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode FillLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(FillLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       	   XCTAssert(layer.fillSortKey == Value<Double>.testConstantValue())
       } catch {
           XCTFail("Failed to decode FillLayer")
       }
    }

    func testEncodingAndDecodingOfPaintProperties() {

       var layer = FillLayer(id: "test-id")
       layer.fillAntialias = Value<Bool>.testConstantValue()
       layer.fillColor = Value<ColorRepresentable>.testConstantValue()
       layer.fillColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillOpacity = Value<Double>.testConstantValue()
       layer.fillOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillOutlineColor = Value<ColorRepresentable>.testConstantValue()
       layer.fillOutlineColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillPattern = Value<ResolvedImage>.testConstantValue()
       layer.fillPatternTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillTranslate = Value<[Double]>.testConstantValue()
       layer.fillTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillTranslateAnchor = Value<FillTranslateAnchor>.testConstantValue()

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode FillLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode FillLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(FillLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       	   XCTAssert(layer.fillAntialias == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.fillColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.fillOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.fillOutlineColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.fillPattern == Value<ResolvedImage>.testConstantValue())
       	   XCTAssert(layer.fillTranslate == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.fillTranslateAnchor == Value<FillTranslateAnchor>.testConstantValue())
       } catch {
           XCTFail("Failed to decode FillLayer")
       }
    }
}

// End of generated file
