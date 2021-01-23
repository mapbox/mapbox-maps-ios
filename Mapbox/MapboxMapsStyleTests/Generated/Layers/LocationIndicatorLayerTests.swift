// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class LocationIndicatorLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

       var layer = LocationIndicatorLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       XCTAssert(layer.id == "test-id")
       XCTAssert(layer.type == LayerType.locationIndicator)
       XCTAssert(layer.filter == nil)
       XCTAssert(layer.source == "some-source")
       XCTAssertNil(layer.sourceLayer)
       XCTAssert(layer.minZoom == 10.0)
       XCTAssert(layer.maxZoom == 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
       var layer = LocationIndicatorLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode LocationIndicatorLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode LocationIndicatorLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(LocationIndicatorLayer.self, from: validData)
           XCTAssert(decodedLayer.id == "test-id")
       	   XCTAssert(decodedLayer.type == LayerType.locationIndicator)
           XCTAssert(decodedLayer.filter == nil)
           XCTAssert(decodedLayer.source == "some-source")
           XCTAssertNil(decodedLayer.sourceLayer)
           XCTAssert(decodedLayer.minZoom == 10.0)
           XCTAssert(decodedLayer.maxZoom == 20.0)
       } catch {
           XCTFail("Failed to decode LocationIndicatorLayer")
       }
    }

    func testEncodingAndDecodingOfLayoutProperties() {

       var layer = LocationIndicatorLayer(id: "test-id")	
       layer.layout?.visibility = .visible
       layer.layout?.bearingImage = Value<ResolvedImage>.testConstantValue()
       layer.layout?.shadowImage = Value<ResolvedImage>.testConstantValue()
       layer.layout?.topImage = Value<ResolvedImage>.testConstantValue()

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode LocationIndicatorLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode LocationIndicatorLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(LocationIndicatorLayer.self, from: validData)
           XCTAssert(decodedLayer.layout?.visibility == .visible)
       	   XCTAssert(layer.layout?.bearingImage == Value<ResolvedImage>.testConstantValue())
       	   XCTAssert(layer.layout?.shadowImage == Value<ResolvedImage>.testConstantValue())
       	   XCTAssert(layer.layout?.topImage == Value<ResolvedImage>.testConstantValue())
 
       } catch {
           XCTFail("Failed to decode LocationIndicatorLayer")
       }
    }
}

// End of generated file