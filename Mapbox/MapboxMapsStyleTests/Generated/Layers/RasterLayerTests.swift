// This file is generated
import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

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
       layer.layout?.visibility = .visible

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
           XCTAssert(decodedLayer.layout?.visibility == .visible)
 
       } catch {
           XCTFail("Failed to decode RasterLayer")
       }
    }

    func testEncodingAndDecodingOfPaintProperties() {

       var layer = RasterLayer(id: "test-id")	
       layer.paint?.rasterBrightnessMax = Value<Double>.testConstantValue()
       layer.paint?.rasterBrightnessMaxTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.rasterBrightnessMin = Value<Double>.testConstantValue()
       layer.paint?.rasterBrightnessMinTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.rasterContrast = Value<Double>.testConstantValue()
       layer.paint?.rasterContrastTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.rasterFadeDuration = Value<Double>.testConstantValue()
       layer.paint?.rasterHueRotate = Value<Double>.testConstantValue()
       layer.paint?.rasterHueRotateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.rasterOpacity = Value<Double>.testConstantValue()
       layer.paint?.rasterOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.paint?.rasterResampling = RasterResampling.testConstantValue()
       layer.paint?.rasterSaturation = Value<Double>.testConstantValue()
       layer.paint?.rasterSaturationTransition = StyleTransition(duration: 10.0, delay: 10.0)

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
           XCTAssert(decodedLayer.layout?.visibility == .visible)
       	   XCTAssert(layer.paint?.rasterBrightnessMax == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.rasterBrightnessMin == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.rasterContrast == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.rasterFadeDuration == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.rasterHueRotate == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.rasterOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.paint?.rasterResampling == RasterResampling.testConstantValue())
       	   XCTAssert(layer.paint?.rasterSaturation == Value<Double>.testConstantValue())
 
       } catch {
           XCTFail("Failed to decode RasterLayer")
       }
    }
}

// End of generated file