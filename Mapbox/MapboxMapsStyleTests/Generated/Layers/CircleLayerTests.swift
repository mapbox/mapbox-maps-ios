// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class CircleLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

       var layer = CircleLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       XCTAssert(layer.id == "test-id")
       XCTAssert(layer.type == LayerType.circle)
       XCTAssert(layer.filter == nil)
       XCTAssert(layer.source == "some-source")
       XCTAssertNil(layer.sourceLayer)
       XCTAssert(layer.minZoom == 10.0)
       XCTAssert(layer.maxZoom == 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
       var layer = CircleLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode CircleLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode CircleLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(CircleLayer.self, from: validData)
           XCTAssert(decodedLayer.id == "test-id")
       	   XCTAssert(decodedLayer.type == LayerType.circle)
           XCTAssert(decodedLayer.filter == nil)
           XCTAssert(decodedLayer.source == "some-source")
           XCTAssertNil(decodedLayer.sourceLayer)
           XCTAssert(decodedLayer.minZoom == 10.0)
           XCTAssert(decodedLayer.maxZoom == 20.0)
       } catch {
           XCTFail("Failed to decode CircleLayer")
       }
    }

    func testEncodingAndDecodingOfLayoutProperties() {

       var layer = CircleLayer(id: "test-id")	
       layer.layout?.visibility = .visible
       layer.layout?.circleSortKey = Value<Double>.testConstantValue()

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode CircleLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode CircleLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(CircleLayer.self, from: validData)
           XCTAssert(decodedLayer.layout?.visibility == .visible)
       	   XCTAssert(layer.layout?.circleSortKey == Value<Double>.testConstantValue())
 
       } catch {
           XCTFail("Failed to decode CircleLayer")
       }
    }
}

// End of generated file