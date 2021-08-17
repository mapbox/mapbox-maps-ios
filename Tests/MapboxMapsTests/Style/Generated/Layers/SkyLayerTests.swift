// This file is generated
import XCTest
@testable import MapboxMaps

class SkyLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

       var layer = SkyLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       XCTAssert(layer.id == "test-id")
       XCTAssert(layer.type == LayerType.sky)
       XCTAssert(layer.filter == nil)
       XCTAssert(layer.source == "some-source")
       XCTAssertNil(layer.sourceLayer)
       XCTAssert(layer.minZoom == 10.0)
       XCTAssert(layer.maxZoom == 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
       var layer = SkyLayer(id: "test-id")
       layer.source = "some-source"
       layer.sourceLayer = nil
       layer.minZoom = 10.0
       layer.maxZoom = 20.0

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode SkyLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode SkyLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(SkyLayer.self, from: validData)
           XCTAssert(decodedLayer.id == "test-id")
       	   XCTAssert(decodedLayer.type == LayerType.sky)
           XCTAssert(decodedLayer.filter == nil)
           XCTAssert(decodedLayer.source == "some-source")
           XCTAssertNil(decodedLayer.sourceLayer)
           XCTAssert(decodedLayer.minZoom == 10.0)
           XCTAssert(decodedLayer.maxZoom == 20.0)
       } catch {
           XCTFail("Failed to decode SkyLayer")
       }
    }

    func testEncodingAndDecodingOfLayoutProperties() {

       var layer = SkyLayer(id: "test-id")
       layer.visibility = .constant(.visible)

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode SkyLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode SkyLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(SkyLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       } catch {
           XCTFail("Failed to decode SkyLayer")
       }
    }

    func testEncodingAndDecodingOfPaintProperties() {

       var layer = SkyLayer(id: "test-id")
       layer.skyAtmosphereColor = Value<ColorRepresentable>.testConstantValue()
       layer.skyAtmosphereHaloColor = Value<ColorRepresentable>.testConstantValue()
       layer.skyAtmosphereSun = Value<[Double]>.testConstantValue()
       layer.skyAtmosphereSunIntensity = Value<Double>.testConstantValue()
       layer.skyGradient = Value<ColorRepresentable>.testConstantValue()
       layer.skyGradientCenter = Value<[Double]>.testConstantValue()
       layer.skyGradientRadius = Value<Double>.testConstantValue()
       layer.skyOpacity = Value<Double>.testConstantValue()
       layer.skyOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.skyType = Value<SkyType>.testConstantValue()

       var data: Data?
       do {
       	   data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode SkyLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode SkyLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(SkyLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       	   XCTAssert(layer.skyAtmosphereColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.skyAtmosphereHaloColor == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.skyAtmosphereSun == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.skyAtmosphereSunIntensity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.skyGradient == Value<ColorRepresentable>.testConstantValue())
       	   XCTAssert(layer.skyGradientCenter == Value<[Double]>.testConstantValue())
       	   XCTAssert(layer.skyGradientRadius == Value<Double>.testConstantValue())
       	   XCTAssert(layer.skyOpacity == Value<Double>.testConstantValue())
       	   XCTAssert(layer.skyType == Value<SkyType>.testConstantValue())
       } catch {
           XCTFail("Failed to decode SkyLayer")
       }
    }
}

// End of generated file
