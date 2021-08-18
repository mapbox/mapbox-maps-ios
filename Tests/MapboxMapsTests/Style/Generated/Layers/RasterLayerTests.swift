// This file is generated
import XCTest
@testable import MapboxMaps

class RasterLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

       var layer = RasterLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       XCTAssert(layer.id == "test-id")
       XCTAssert(layer.type == LayerType.raster)
       XCTAssert(layer.filter == nil)
       XCTAssert(layer.source == "some-source")
       XCTAssertNil(layer.sourceLayer)
       XCTAssert(layer.minZoom == 10.0)
       XCTAssert(layer.maxZoom == 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
       var layer = RasterLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode RasterLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode RasterLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(RasterLayer.self, from: validData)
           XCTAssert(decodedLayer.id == "test-id")
       	   XCTAssert(decodedLayer.type == LayerType.raster)
           XCTAssert(decodedLayer.filter == nil)
           XCTAssert(decodedLayer.source == "some-source")
           XCTAssertNil(decodedLayer.sourceLayer)
           XCTAssert(decodedLayer.minZoom == 10.0)
           XCTAssert(decodedLayer.maxZoom == 20.0)
       } catch {
           XCTFail("Failed to decode RasterLayer")
       }
    }

    func testEncodingAndDecodingOfLayoutProperties() {

       var layer = RasterLayer(id: "test-id")
       layer.visibility = .constant(.visible)

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode RasterLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode RasterLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(RasterLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       } catch {
           XCTFail("Failed to decode RasterLayer")
       }
    }

    func testEncodingAndDecodingOfPaintProperties() {

       var layer = RasterLayer(id: "test-id")
       layer.rasterBrightnessMax = Value<Double>.testConstantValue()
       layer.rasterBrightnessMaxTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterBrightnessMin = Value<Double>.testConstantValue()
       layer.rasterBrightnessMinTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterContrast = Value<Double>.testConstantValue()
       layer.rasterContrastTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterFadeDuration = Value<Double>.testConstantValue()
       layer.rasterHueRotate = Value<Double>.testConstantValue()
       layer.rasterHueRotateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterOpacity = Value<Double>.testConstantValue()
       layer.rasterOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterResampling = Value<RasterResampling>.testConstantValue()
       layer.rasterSaturation = Value<Double>.testConstantValue()
       layer.rasterSaturationTransition = StyleTransition(duration: 10.0, delay: 10.0)

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode RasterLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode RasterLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(RasterLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       	   XCTAssert(layer.rasterBrightnessMax == Value<Double>.testConstantValue())
       	   XCTAssert(layer.rasterBrightnessMin == Value<Double>.testConstantValue())
       	   XCTAssert(layer.rasterContrast == Value<Double>.testConstantValue())
       	   XCTAssert(layer.rasterFadeDuration == Value<Double>.testConstantValue())
       	   XCTAssert(layer.rasterHueRotate == Value<Double>.testConstantValue())
       	   XCTAssert(layer.rasterOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.rasterResampling == Value<RasterResampling>.testConstantValue())
       	   XCTAssert(layer.rasterSaturation == Value<Double>.testConstantValue())
       } catch {
           XCTFail("Failed to decode RasterLayer")
       }
    }
}

// End of generated file
