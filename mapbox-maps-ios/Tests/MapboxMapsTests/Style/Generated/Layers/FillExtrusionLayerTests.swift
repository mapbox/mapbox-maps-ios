// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class FillExtrusionLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = FillExtrusionLayer(id: "test-id")
        layer.source = "some-source"
        layer.sourceLayer = nil
        layer.minZoom = 10.0
        layer.maxZoom = 20.0

        XCTAssert(layer.id == "test-id")
        XCTAssert(layer.type == LayerType.fillExtrusion)
        XCTAssert(layer.filter == nil)
        XCTAssert(layer.source == "some-source")
        XCTAssertNil(layer.sourceLayer)
        XCTAssert(layer.minZoom == 10.0)
        XCTAssert(layer.maxZoom == 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = FillExtrusionLayer(id: "test-id")
        layer.source = "some-source"
        layer.sourceLayer = nil
        layer.minZoom = 10.0
        layer.maxZoom = 20.0

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode FillExtrusionLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode FillExtrusionLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(FillExtrusionLayer.self, from: validData)
            XCTAssert(decodedLayer.id == "test-id")
            XCTAssert(decodedLayer.type == LayerType.fillExtrusion)
            XCTAssert(decodedLayer.filter == nil)
            XCTAssert(decodedLayer.source == "some-source")
            XCTAssertNil(decodedLayer.sourceLayer)
            XCTAssert(decodedLayer.minZoom == 10.0)
            XCTAssert(decodedLayer.maxZoom == 20.0)
        } catch {
            XCTFail("Failed to decode FillExtrusionLayer")
        }
    }

    func testEncodingAndDecodingOfLayoutProperties() {
        var layer = FillExtrusionLayer(id: "test-id")
        layer.visibility = .visible
        layer.fillExtrusionEdgeRadius = Value<Double>.testConstantValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode FillExtrusionLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode FillExtrusionLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(FillExtrusionLayer.self, from: validData)
            XCTAssert(decodedLayer.visibility == .visible)
            XCTAssert(layer.fillExtrusionEdgeRadius == Value<Double>.testConstantValue())
        } catch {
            XCTFail("Failed to decode FillExtrusionLayer")
        }
    }

    func testEncodingAndDecodingOfPaintProperties() {
       var layer = FillExtrusionLayer(id: "test-id")
       layer.fillExtrusionAmbientOcclusionGroundAttenuation = Value<Double>.testConstantValue()
       layer.fillExtrusionAmbientOcclusionGroundAttenuationTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionAmbientOcclusionGroundRadius = Value<Double>.testConstantValue()
       layer.fillExtrusionAmbientOcclusionGroundRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionAmbientOcclusionIntensity = Value<Double>.testConstantValue()
       layer.fillExtrusionAmbientOcclusionIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionAmbientOcclusionRadius = Value<Double>.testConstantValue()
       layer.fillExtrusionAmbientOcclusionRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionAmbientOcclusionWallRadius = Value<Double>.testConstantValue()
       layer.fillExtrusionAmbientOcclusionWallRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionBase = Value<Double>.testConstantValue()
       layer.fillExtrusionBaseTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionColor = Value<StyleColor>.testConstantValue()
       layer.fillExtrusionColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionFloodLightColor = Value<StyleColor>.testConstantValue()
       layer.fillExtrusionFloodLightColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionFloodLightGroundAttenuation = Value<Double>.testConstantValue()
       layer.fillExtrusionFloodLightGroundAttenuationTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionFloodLightGroundRadius = Value<Double>.testConstantValue()
       layer.fillExtrusionFloodLightGroundRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionFloodLightIntensity = Value<Double>.testConstantValue()
       layer.fillExtrusionFloodLightIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionFloodLightWallRadius = Value<Double>.testConstantValue()
       layer.fillExtrusionFloodLightWallRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionHeight = Value<Double>.testConstantValue()
       layer.fillExtrusionHeightTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionOpacity = Value<Double>.testConstantValue()
       layer.fillExtrusionOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionPattern = Value<ResolvedImage>.testConstantValue()
       layer.fillExtrusionRoundedRoof = Value<Bool>.testConstantValue()
       layer.fillExtrusionTranslate = Value<[Double]>.testConstantValue()
       layer.fillExtrusionTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillExtrusionTranslateAnchor = Value<FillExtrusionTranslateAnchor>.testConstantValue()
       layer.fillExtrusionVerticalGradient = Value<Bool>.testConstantValue()
       layer.fillExtrusionVerticalScale = Value<Double>.testConstantValue()
       layer.fillExtrusionVerticalScaleTransition = StyleTransition(duration: 10.0, delay: 10.0)

       var data: Data?
       do {
           data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode FillExtrusionLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode FillExtrusionLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(FillExtrusionLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .visible)
           XCTAssert(layer.fillExtrusionAmbientOcclusionGroundAttenuation == Value<Double>.testConstantValue())
           XCTAssert(layer.fillExtrusionAmbientOcclusionGroundRadius == Value<Double>.testConstantValue())
           XCTAssert(layer.fillExtrusionAmbientOcclusionIntensity == Value<Double>.testConstantValue())
           XCTAssert(layer.fillExtrusionAmbientOcclusionRadius == Value<Double>.testConstantValue())
           XCTAssert(layer.fillExtrusionAmbientOcclusionWallRadius == Value<Double>.testConstantValue())
           XCTAssert(layer.fillExtrusionBase == Value<Double>.testConstantValue())
           XCTAssert(layer.fillExtrusionColor == Value<StyleColor>.testConstantValue())
           XCTAssert(layer.fillExtrusionFloodLightColor == Value<StyleColor>.testConstantValue())
           XCTAssert(layer.fillExtrusionFloodLightGroundAttenuation == Value<Double>.testConstantValue())
           XCTAssert(layer.fillExtrusionFloodLightGroundRadius == Value<Double>.testConstantValue())
           XCTAssert(layer.fillExtrusionFloodLightIntensity == Value<Double>.testConstantValue())
           XCTAssert(layer.fillExtrusionFloodLightWallRadius == Value<Double>.testConstantValue())
           XCTAssert(layer.fillExtrusionHeight == Value<Double>.testConstantValue())
           XCTAssert(layer.fillExtrusionOpacity == Value<Double>.testConstantValue())
           XCTAssert(layer.fillExtrusionPattern == Value<ResolvedImage>.testConstantValue())
           XCTAssert(layer.fillExtrusionRoundedRoof == Value<Bool>.testConstantValue())
           XCTAssert(layer.fillExtrusionTranslate == Value<[Double]>.testConstantValue())
           XCTAssert(layer.fillExtrusionTranslateAnchor == Value<FillExtrusionTranslateAnchor>.testConstantValue())
           XCTAssert(layer.fillExtrusionVerticalGradient == Value<Bool>.testConstantValue())
           XCTAssert(layer.fillExtrusionVerticalScale == Value<Double>.testConstantValue())
       } catch {
           XCTFail("Failed to decode FillExtrusionLayer")
       }
    }
}

// End of generated file
