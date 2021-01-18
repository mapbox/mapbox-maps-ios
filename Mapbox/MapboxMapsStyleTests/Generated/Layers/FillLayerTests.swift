// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

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
       layer.layout?.visibility = .visible
       layer.layout?.fillSortKey = Value<Double>.testConstantValue()

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
           XCTAssert(decodedLayer.layout?.visibility == .visible)
       	   XCTAssert(layer.layout?.fillSortKey == Value<Double>.testConstantValue())
 
       } catch {
           XCTFail("Failed to decode FillLayer")
       }
    }

    func testEncodingAndDecodingOfPaintProperties() {

       var layer = FillLayer(id: "test-id")	
       layer.paint?.fillAntialias = Value<Bool>.testConstantValue()
       layer.paint?.fillColor = Value<ColorRepresentable>.testConstantValue()
       layer.paint?.fillColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.fillOpacity = Value<Double>.testConstantValue()
       layer.paint?.fillOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.fillOutlineColor = Value<ColorRepresentable>.testConstantValue()
       layer.paint?.fillOutlineColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.fillPattern = Value<ResolvedImage>.testConstantValue()
       layer.paint?.fillPatternTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.fillTranslate = Value<[Double]>.testConstantValue()
       layer.paint?.fillTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.fillTranslateAnchor = FillTranslateAnchor.testConstantValue()

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
           XCTAssert(decodedLayer.layout?.visibility == .visible)
       	   XCTAssert(layer.paint?.fillAntialias == Value<Bool>.testConstantValue())
       	   XCTAssert(layer.paint?.fillColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.paint?.fillOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.fillOutlineColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.paint?.fillPattern == Value<ResolvedImage>.testConstantValue())
       	   XCTAssert(layer.paint?.fillTranslate == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.paint?.fillTranslateAnchor == FillTranslateAnchor.testConstantValue())
 
       } catch {
           XCTFail("Failed to decode FillLayer")
       }
    }
}

// End of generated file