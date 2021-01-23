// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class LineLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

       var layer = LineLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       XCTAssert(layer.id == "test-id")
       XCTAssert(layer.type == LayerType.line)
       XCTAssert(layer.filter == nil)
       XCTAssert(layer.source == "some-source")
       XCTAssertNil(layer.sourceLayer)
       XCTAssert(layer.minZoom == 10.0)
       XCTAssert(layer.maxZoom == 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
       var layer = LineLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode LineLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode LineLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(LineLayer.self, from: validData)
           XCTAssert(decodedLayer.id == "test-id")
       	   XCTAssert(decodedLayer.type == LayerType.line)
           XCTAssert(decodedLayer.filter == nil)
           XCTAssert(decodedLayer.source == "some-source")
           XCTAssertNil(decodedLayer.sourceLayer)
           XCTAssert(decodedLayer.minZoom == 10.0)
           XCTAssert(decodedLayer.maxZoom == 20.0)
       } catch {
           XCTFail("Failed to decode LineLayer")
       }
    }

    func testEncodingAndDecodingOfLayoutProperties() {

       var layer = LineLayer(id: "test-id")	
       layer.layout?.visibility = .visible
       layer.layout?.lineCap = LineCap.testConstantValue()
       layer.layout?.lineJoin = LineJoin.testConstantValue()
       layer.layout?.lineMiterLimit = Value<Double>.testConstantValue()
       layer.layout?.lineRoundLimit = Value<Double>.testConstantValue()
       layer.layout?.lineSortKey = Value<Double>.testConstantValue()

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode LineLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode LineLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(LineLayer.self, from: validData)
           XCTAssert(decodedLayer.layout?.visibility == .visible)
       	   XCTAssert(layer.layout?.lineCap == LineCap.testConstantValue())
       	   XCTAssert(layer.layout?.lineJoin == LineJoin.testConstantValue())
       	   XCTAssert(layer.layout?.lineMiterLimit == Value<Double>.testConstantValue())
       	   XCTAssert(layer.layout?.lineRoundLimit == Value<Double>.testConstantValue())
       	   XCTAssert(layer.layout?.lineSortKey == Value<Double>.testConstantValue())
 
       } catch {
           XCTFail("Failed to decode LineLayer")
       }
    }
}

// End of generated file