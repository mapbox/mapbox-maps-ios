// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class HillshadeLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

       var layer = HillshadeLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       XCTAssert(layer.id == "test-id")
       XCTAssert(layer.type == LayerType.hillshade)
       XCTAssert(layer.filter == nil)
       XCTAssert(layer.source == "some-source")
       XCTAssertNil(layer.sourceLayer)
       XCTAssert(layer.minZoom == 10.0)
       XCTAssert(layer.maxZoom == 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
       var layer = HillshadeLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode HillshadeLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode HillshadeLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(HillshadeLayer.self, from: validData)
           XCTAssert(decodedLayer.id == "test-id")
       	   XCTAssert(decodedLayer.type == LayerType.hillshade)
           XCTAssert(decodedLayer.filter == nil)
           XCTAssert(decodedLayer.source == "some-source")
           XCTAssertNil(decodedLayer.sourceLayer)
           XCTAssert(decodedLayer.minZoom == 10.0)
           XCTAssert(decodedLayer.maxZoom == 20.0)
       } catch {
           XCTFail("Failed to decode HillshadeLayer")
       }
    }

    func testEncodingAndDecodingOfLayoutProperties() {

       var layer = HillshadeLayer(id: "test-id")	
       layer.layout?.visibility = .visible

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode HillshadeLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode HillshadeLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(HillshadeLayer.self, from: validData)
           XCTAssert(decodedLayer.layout?.visibility == .visible)
 
       } catch {
           XCTFail("Failed to decode HillshadeLayer")
       }
    }
}

// End of generated file