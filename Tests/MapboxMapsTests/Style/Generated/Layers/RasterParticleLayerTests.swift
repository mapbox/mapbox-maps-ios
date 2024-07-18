// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class RasterParticleLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = RasterParticleLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.rasterParticle)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = RasterParticleLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode RasterParticleLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode RasterParticleLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(RasterParticleLayer.self, from: validData)
            XCTAssertEqual(decodedLayer.id, "test-id")
            XCTAssertEqual(decodedLayer.type, LayerType.rasterParticle)
            XCTAssert(decodedLayer.source == "source")
            XCTAssertEqual(decodedLayer.minZoom, 10.0)
            XCTAssertEqual(decodedLayer.maxZoom, 20.0)
            XCTAssertEqual(layer.slot, Slot.testConstantValue())
        } catch {
            XCTFail("Failed to decode RasterParticleLayer")
        }
    }

    func testEncodingAndDecodingOfLayoutProperties() {
        var layer = RasterParticleLayer(id: "test-id", source: "source")
        layer.visibility = .constant(.visible)

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode RasterParticleLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode RasterParticleLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(RasterParticleLayer.self, from: validData)
            XCTAssert(decodedLayer.visibility == .constant(.visible))
        } catch {
            XCTFail("Failed to decode RasterParticleLayer")
        }
    }

    func testEncodingAndDecodingOfPaintProperties() {
       var layer = RasterParticleLayer(id: "test-id", source: "source")
       layer.rasterParticleArrayBand = Value<String>.testConstantValue()
       layer.rasterParticleColor = Value<StyleColor>.testConstantValue()
       layer.rasterParticleCount = Value<Double>.testConstantValue()
       layer.rasterParticleFadeOpacityFactor = Value<Double>.testConstantValue()
       layer.rasterParticleFadeOpacityFactorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterParticleMaxSpeed = Value<Double>.testConstantValue()
       layer.rasterParticleResetRateFactor = Value<Double>.testConstantValue()
       layer.rasterParticleSpeedFactor = Value<Double>.testConstantValue()
       layer.rasterParticleSpeedFactorTransition = StyleTransition(duration: 10.0, delay: 10.0)

       var data: Data?
       do {
           data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode RasterParticleLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode RasterParticleLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(RasterParticleLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
           XCTAssertEqual(layer.rasterParticleArrayBand, Value<String>.testConstantValue())
           XCTAssertEqual(layer.rasterParticleColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.rasterParticleCount, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterParticleFadeOpacityFactor, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterParticleMaxSpeed, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterParticleResetRateFactor, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterParticleSpeedFactor, Value<Double>.testConstantValue())
       } catch {
           XCTFail("Failed to decode RasterParticleLayer")
       }
    }

    func testSetPropertyValueWithFunction() {
        let layer = RasterParticleLayer(id: "test-id", source: "source")
            .filter(Exp.testConstantValue())
            .source(String.testConstantValue())
            .sourceLayer(String.testConstantValue())
            .slot(Slot.testConstantValue())
            .minZoom(Double.testConstantValue())
            .maxZoom(Double.testConstantValue())
            .rasterParticleArrayBand(String.testConstantValue())
            .rasterParticleColor(StyleColor.testConstantValue())
            .rasterParticleCount(Double.testConstantValue())
            .rasterParticleFadeOpacityFactor(Double.testConstantValue())
            .rasterParticleMaxSpeed(Double.testConstantValue())
            .rasterParticleResetRateFactor(Double.testConstantValue())
            .rasterParticleSpeedFactor(Double.testConstantValue())

        XCTAssertEqual(layer.filter, Exp.testConstantValue())
        XCTAssertEqual(layer.source, String.testConstantValue())
        XCTAssertEqual(layer.sourceLayer, String.testConstantValue())
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
        XCTAssertEqual(layer.minZoom, Double.testConstantValue())
        XCTAssertEqual(layer.maxZoom, Double.testConstantValue())
        XCTAssertEqual(layer.rasterParticleArrayBand, Value.constant(String.testConstantValue()))
        XCTAssertEqual(layer.rasterParticleColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.rasterParticleCount, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.rasterParticleFadeOpacityFactor, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.rasterParticleMaxSpeed, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.rasterParticleResetRateFactor, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.rasterParticleSpeedFactor, Value.constant(Double.testConstantValue()))
    }
}

// End of generated file
