// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class ModelLayerTests: XCTestCase {

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
        layer.visibility = .constant(.visible)
        layer.modelId = Value<String>.testConstantValue()

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
            XCTAssert(decodedLayer.visibility == .constant(.visible))
            XCTAssert(layer.modelId == Value<String>.testConstantValue())
        } catch {
            XCTFail("Failed to decode ModelLayer")
        }
    }

    func testEncodingAndDecodingOfPaintProperties() {
       var layer = ModelLayer(id: "test-id")
       layer.modelColor = Value<StyleColor>.testConstantValue()
       layer.modelColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.modelColorMixIntensity = Value<Double>.testConstantValue()
       layer.modelColorMixIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.modelOpacity = Value<Double>.testConstantValue()
       layer.modelOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.modelRotation = Value<[Double]>.testConstantValue()
       layer.modelRotationTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.modelScale = Value<[Double]>.testConstantValue()
       layer.modelScaleTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.modelTranslation = Value<[Double]>.testConstantValue()
       layer.modelTranslationTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.modelType = Value<ModelType>.testConstantValue()

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
           XCTAssert(decodedLayer.visibility == .constant(.visible))
           XCTAssert(layer.modelColor == Value<StyleColor>.testConstantValue())
           XCTAssert(layer.modelColorMixIntensity == Value<Double>.testConstantValue())
           XCTAssert(layer.modelOpacity == Value<Double>.testConstantValue())
           XCTAssert(layer.modelRotation == Value<[Double]>.testConstantValue())
           XCTAssert(layer.modelScale == Value<[Double]>.testConstantValue())
           XCTAssert(layer.modelTranslation == Value<[Double]>.testConstantValue())
           XCTAssert(layer.modelType == Value<ModelType>.testConstantValue())
       } catch {
           XCTFail("Failed to decode ModelLayer")
       }
    }
}

// End of generated file
