// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class SkyLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = SkyLayer(id: "test-id")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.sky)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = SkyLayer(id: "test-id")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

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
            XCTAssertEqual(decodedLayer.id, "test-id")
            XCTAssertEqual(decodedLayer.type, LayerType.sky)
            XCTAssertEqual(decodedLayer.minZoom, 10.0)
            XCTAssertEqual(decodedLayer.maxZoom, 20.0)
            XCTAssertEqual(layer.slot, Slot.testConstantValue())
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
       layer.skyAtmosphereColor = Value<StyleColor>.testConstantValue()
       layer.skyAtmosphereHaloColor = Value<StyleColor>.testConstantValue()
       layer.skyAtmosphereSun = Value<[Double]>.testConstantValue()
       layer.skyAtmosphereSunIntensity = Value<Double>.testConstantValue()
       layer.skyGradient = Value<StyleColor>.testConstantValue()
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
           XCTAssertEqual(layer.skyAtmosphereColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.skyAtmosphereHaloColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.skyAtmosphereSun, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.skyAtmosphereSunIntensity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.skyGradient, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.skyGradientCenter, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.skyGradientRadius, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.skyOpacity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.skyType, Value<SkyType>.testConstantValue())
       } catch {
           XCTFail("Failed to decode SkyLayer")
       }
    }

    func testSetPropertyValueWithFunction() {
        let layer = SkyLayer(id: "test-id")
            .slot(Slot.testConstantValue())
            .minZoom(Double.testConstantValue())
            .maxZoom(Double.testConstantValue())
            .skyAtmosphereColor(StyleColor.testConstantValue())
            .skyAtmosphereHaloColor(StyleColor.testConstantValue())
            .skyAtmosphereSun(azimuthal: 0, polar: 1)
            .skyAtmosphereSunIntensity(Double.testConstantValue())
            .skyGradient(StyleColor.testConstantValue())
            .skyGradientCenter(azimuthal: 0, polar: 1)
            .skyGradientRadius(Double.testConstantValue())
            .skyOpacity(Double.testConstantValue())
            .skyType(SkyType.testConstantValue())

        XCTAssertEqual(layer.slot, Slot.testConstantValue())
        XCTAssertEqual(layer.minZoom, Double.testConstantValue())
        XCTAssertEqual(layer.maxZoom, Double.testConstantValue())
        XCTAssertEqual(layer.skyAtmosphereColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.skyAtmosphereHaloColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.skyAtmosphereSun, Value.constant([0, 1]))
        XCTAssertEqual(layer.skyAtmosphereSunIntensity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.skyGradient, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.skyGradientCenter, Value.constant([0, 1]))
        XCTAssertEqual(layer.skyGradientRadius, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.skyOpacity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.skyType, Value.constant(SkyType.testConstantValue()))
    }
}

// End of generated file
