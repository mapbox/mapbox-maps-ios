// This file is generated
import XCTest
@testable import MapboxMaps

class HeatmapLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

       var layer = HeatmapLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       XCTAssert(layer.id == "test-id")
       XCTAssert(layer.type == LayerType.heatmap)
       XCTAssert(layer.filter == nil)
       XCTAssert(layer.source == "some-source")
       XCTAssertNil(layer.sourceLayer)
       XCTAssert(layer.minZoom == 10.0)
       XCTAssert(layer.maxZoom == 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
       var layer = HeatmapLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode HeatmapLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode HeatmapLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(HeatmapLayer.self, from: validData)
           XCTAssert(decodedLayer.id == "test-id")
       	   XCTAssert(decodedLayer.type == LayerType.heatmap)
           XCTAssert(decodedLayer.filter == nil)
           XCTAssert(decodedLayer.source == "some-source")
           XCTAssertNil(decodedLayer.sourceLayer)
           XCTAssert(decodedLayer.minZoom == 10.0)
           XCTAssert(decodedLayer.maxZoom == 20.0)
       } catch {
           XCTFail("Failed to decode HeatmapLayer")
       }
    }

    func testEncodingAndDecodingOfLayoutProperties() {

       var layer = HeatmapLayer(id: "test-id")
       layer.visibility = .constant(.visible)

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode HeatmapLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode HeatmapLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(HeatmapLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       } catch {
           XCTFail("Failed to decode HeatmapLayer")
       }
    }

    func testEncodingAndDecodingOfPaintProperties() {

       var layer = HeatmapLayer(id: "test-id")
       layer.heatmapColor = Value<ColorRepresentable>.testConstantValue()
       layer.heatmapIntensity = Value<Double>.testConstantValue()
       layer.heatmapIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.heatmapOpacity = Value<Double>.testConstantValue()
       layer.heatmapOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.heatmapRadius = Value<Double>.testConstantValue()
       layer.heatmapRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.heatmapWeight = Value<Double>.testConstantValue()

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode HeatmapLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode HeatmapLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(HeatmapLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       	   XCTAssert(layer.heatmapColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.heatmapIntensity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.heatmapOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.heatmapRadius == Value<Double>.testConstantValue())
       	   XCTAssert(layer.heatmapWeight == Value<Double>.testConstantValue())
       } catch {
           XCTFail("Failed to decode HeatmapLayer")
       }
    }
}

// End of generated file
