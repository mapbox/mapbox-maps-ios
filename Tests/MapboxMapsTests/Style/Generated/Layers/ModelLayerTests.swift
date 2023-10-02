// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class ModelLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = ModelLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.model)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = ModelLayer(id: "test-id", source: "source")
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
            XCTAssertEqual(decodedLayer.id, "test-id")
            XCTAssertEqual(decodedLayer.type, LayerType.model)
            XCTAssert(decodedLayer.source == "source")
            XCTAssertEqual(decodedLayer.minZoom, 10.0)
            XCTAssertEqual(decodedLayer.maxZoom, 20.0)
        } catch {
            XCTFail("Failed to decode ModelLayer")
        }
    }

    func testEncodingAndDecodingOfLayoutProperties() {
        var layer = ModelLayer(id: "test-id", source: "source")
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
            XCTAssertEqual(layer.modelId, Value<String>.testConstantValue())
        } catch {
            XCTFail("Failed to decode ModelLayer")
        }
    }

    func testEncodingAndDecodingOfPaintProperties() {
       var layer = ModelLayer(id: "test-id", source: "source")
       layer.modelAmbientOcclusionIntensity = Value<Double>.testConstantValue()
       layer.modelAmbientOcclusionIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.modelCastShadows = Value<Bool>.testConstantValue()
       layer.modelColor = Value<StyleColor>.testConstantValue()
       layer.modelColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.modelColorMixIntensity = Value<Double>.testConstantValue()
       layer.modelColorMixIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.modelCutoffFadeRange = Value<Double>.testConstantValue()
       layer.modelEmissiveStrength = Value<Double>.testConstantValue()
       layer.modelEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.modelHeightBasedEmissiveStrengthMultiplier = Value<[Double]>.testConstantValue()
       layer.modelHeightBasedEmissiveStrengthMultiplierTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.modelOpacity = Value<Double>.testConstantValue()
       layer.modelOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.modelReceiveShadows = Value<Bool>.testConstantValue()
       layer.modelRotation = Value<[Double]>.testConstantValue()
       layer.modelRotationTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.modelRoughness = Value<Double>.testConstantValue()
       layer.modelRoughnessTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.modelScale = Value<[Double]>.testConstantValue()
       layer.modelScaleTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.modelScaleMode = Value<ModelScaleMode>.testConstantValue()
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
           XCTAssertEqual(layer.modelAmbientOcclusionIntensity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.modelCastShadows, Value<Bool>.testConstantValue())
           XCTAssertEqual(layer.modelColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.modelColorMixIntensity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.modelCutoffFadeRange, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.modelEmissiveStrength, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.modelHeightBasedEmissiveStrengthMultiplier, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.modelOpacity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.modelReceiveShadows, Value<Bool>.testConstantValue())
           XCTAssertEqual(layer.modelRotation, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.modelRoughness, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.modelScale, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.modelScaleMode, Value<ModelScaleMode>.testConstantValue())
           XCTAssertEqual(layer.modelTranslation, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.modelType, Value<ModelType>.testConstantValue())
       } catch {
           XCTFail("Failed to decode ModelLayer")
       }
    }
}

// End of generated file
