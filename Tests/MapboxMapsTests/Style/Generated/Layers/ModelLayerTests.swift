// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class ModelLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = ModelLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.model)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = ModelLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

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
            XCTAssertEqual(layer.slot, Slot.testConstantValue())
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
       layer.modelFrontCutoff = Value<[Double]>.testConstantValue()
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
           XCTAssertEqual(layer.modelFrontCutoff, Value<[Double]>.testConstantValue())
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

    func testSetPropertyValueWithFunction() {
        let layer = ModelLayer(id: "test-id", source: "source")
            .filter(Exp.testConstantValue())
            .source(String.testConstantValue())
            .sourceLayer(String.testConstantValue())
            .slot(Slot.testConstantValue())
            .minZoom(Double.testConstantValue())
            .maxZoom(Double.testConstantValue())
            .modelId(String.testConstantValue())
            .modelAmbientOcclusionIntensity(Double.testConstantValue())
            .modelCastShadows(Bool.testConstantValue())
            .modelColor(StyleColor.testConstantValue())
            .modelColorMixIntensity(Double.testConstantValue())
            .modelCutoffFadeRange(Double.testConstantValue())
            .modelEmissiveStrength(Double.testConstantValue())
            .modelFrontCutoff(start: 0, range: 1, end: 2)
            .modelHeightBasedEmissiveStrengthMultiplier(gradientBegin: 0, gradientEnd: 1, valueAtBegin: 2, valueAtEnd: 3, gradientCurvePower: 4)
            .modelOpacity(Double.testConstantValue())
            .modelReceiveShadows(Bool.testConstantValue())
            .modelRotation(x: 0, y: 1, z: 2)
            .modelRoughness(Double.testConstantValue())
            .modelScale(x: 0, y: 1, z: 2)
            .modelScaleMode(ModelScaleMode.testConstantValue())
            .modelTranslation(x: 0, y: 1, z: 2)
            .modelType(ModelType.testConstantValue())

        XCTAssertEqual(layer.filter, Exp.testConstantValue())
        XCTAssertEqual(layer.source, String.testConstantValue())
        XCTAssertEqual(layer.sourceLayer, String.testConstantValue())
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
        XCTAssertEqual(layer.minZoom, Double.testConstantValue())
        XCTAssertEqual(layer.maxZoom, Double.testConstantValue())
        XCTAssertEqual(layer.modelId, Value.constant(String.testConstantValue()))
        XCTAssertEqual(layer.modelAmbientOcclusionIntensity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.modelCastShadows, Value.constant(Bool.testConstantValue()))
        XCTAssertEqual(layer.modelColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.modelColorMixIntensity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.modelCutoffFadeRange, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.modelEmissiveStrength, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.modelFrontCutoff, Value.constant([0, 1, 2]))
        XCTAssertEqual(layer.modelHeightBasedEmissiveStrengthMultiplier, Value.constant([0, 1, 2, 3, 4]))
        XCTAssertEqual(layer.modelOpacity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.modelReceiveShadows, Value.constant(Bool.testConstantValue()))
        XCTAssertEqual(layer.modelRotation, Value.constant([0, 1, 2]))
        XCTAssertEqual(layer.modelRoughness, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.modelScale, Value.constant([0, 1, 2]))
        XCTAssertEqual(layer.modelScaleMode, Value.constant(ModelScaleMode.testConstantValue()))
        XCTAssertEqual(layer.modelTranslation, Value.constant([0, 1, 2]))
        XCTAssertEqual(layer.modelType, Value.constant(ModelType.testConstantValue()))
    }
}

// End of generated file
