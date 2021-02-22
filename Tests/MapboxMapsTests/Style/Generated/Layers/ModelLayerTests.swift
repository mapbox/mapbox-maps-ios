// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class ModelLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

       var layer = ModelLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       XCTAssert(layer.id == "test-id")
       XCTAssert(layer.type == LayerType.model)
       XCTAssert(layer.filter == nil)
       XCTAssert(layer.source == "some-source")
       XCTAssertNil(layer.sourceLayer)
       XCTAssert(layer.minZoom == 10.0)
       XCTAssert(layer.maxZoom == 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
       var layer = ModelLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode ModelLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode ModelLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(ModelLayer.self, from: validData)
           XCTAssert(decodedLayer.id == "test-id")
       	   XCTAssert(decodedLayer.type == LayerType.model)
           XCTAssert(decodedLayer.filter == nil)
           XCTAssert(decodedLayer.source == "some-source")
           XCTAssertNil(decodedLayer.sourceLayer)
           XCTAssert(decodedLayer.minZoom == 10.0)
           XCTAssert(decodedLayer.maxZoom == 20.0)
       } catch {
           XCTFail("Failed to decode ModelLayer")
       }
    }

    func testEncodingAndDecodingOfLayoutProperties() {

       var layer = ModelLayer(id: "test-id")	
       layer.layout?.visibility = .visible

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode ModelLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode ModelLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(ModelLayer.self, from: validData)
           XCTAssert(decodedLayer.layout?.visibility == .visible)
 
       } catch {
           XCTFail("Failed to decode ModelLayer")
       }
    }

    func testEncodingAndDecodingOfPaintProperties() {

       var layer = ModelLayer(id: "test-id")	
       layer.paint?.modelOpacity = Value<Double>.testConstantValue()
       layer.paint?.modelOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.modelRotation = Value<[Double]>.testConstantValue()
       layer.paint?.modelRotationTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.modelScale = Value<[Double]>.testConstantValue()
       layer.paint?.modelTranslation = Value<[Double]>.testConstantValue()

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode ModelLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode ModelLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(ModelLayer.self, from: validData)
           XCTAssert(decodedLayer.layout?.visibility == .visible)
       	   XCTAssert(layer.paint?.modelOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.modelRotation == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.paint?.modelScale == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.paint?.modelTranslation == Value<[Double]>.testConstantValue())
 
       } catch {
           XCTFail("Failed to decode ModelLayer")
       }
    }
}

// End of generated file