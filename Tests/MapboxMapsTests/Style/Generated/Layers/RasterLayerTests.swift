// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class RasterLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = RasterLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.raster)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = RasterLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

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
            XCTAssertEqual(decodedLayer.id, "test-id")
            XCTAssertEqual(decodedLayer.type, LayerType.raster)
            XCTAssert(decodedLayer.source == "source")
            XCTAssertEqual(decodedLayer.minZoom, 10.0)
            XCTAssertEqual(decodedLayer.maxZoom, 20.0)
            XCTAssertEqual(layer.slot, Slot.testConstantValue())
        } catch {
            XCTFail("Failed to decode RasterLayer")
        }
    }

    func testEncodingAndDecodingOfLayoutProperties() {
        var layer = RasterLayer(id: "test-id", source: "source")
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
       var layer = RasterLayer(id: "test-id", source: "source")
       layer.rasterArrayBand = Value<String>.testConstantValue()
       layer.rasterBrightnessMax = Value<Double>.testConstantValue()
       layer.rasterBrightnessMaxTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterBrightnessMin = Value<Double>.testConstantValue()
       layer.rasterBrightnessMinTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterColor = Value<StyleColor>.testConstantValue()
       layer.rasterColorMix = Value<[Double]>.testConstantValue()
       layer.rasterColorMixTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterColorRange = Value<[Double]>.testConstantValue()
       layer.rasterColorRangeTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterContrast = Value<Double>.testConstantValue()
       layer.rasterContrastTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterElevation = Value<Double>.testConstantValue()
       layer.rasterElevationTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.rasterEmissiveStrength = Value<Double>.testConstantValue()
       layer.rasterEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
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
           XCTAssertEqual(layer.rasterArrayBand, Value<String>.testConstantValue())
           XCTAssertEqual(layer.rasterBrightnessMax, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterBrightnessMin, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.rasterColorMix, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.rasterColorRange, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.rasterContrast, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterElevation, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterEmissiveStrength, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterFadeDuration, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterHueRotate, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterOpacity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.rasterResampling, Value<RasterResampling>.testConstantValue())
           XCTAssertEqual(layer.rasterSaturation, Value<Double>.testConstantValue())
       } catch {
           XCTFail("Failed to decode RasterLayer")
       }
    }

    func testSetPropertyValueWithFunction() {
        let layer = RasterLayer(id: "test-id", source: "source")
            .filter(Exp.testConstantValue())
            .source(String.testConstantValue())
            .sourceLayer(String.testConstantValue())
            .slot(Slot.testConstantValue())
            .minZoom(Double.testConstantValue())
            .maxZoom(Double.testConstantValue())
            .rasterArrayBand(String.testConstantValue())
            .rasterBrightnessMax(Double.testConstantValue())
            .rasterBrightnessMin(Double.testConstantValue())
            .rasterColor(StyleColor.testConstantValue())
            .rasterColorMix(red: 0, green: 1, blue: 2, offset: 3)
            .rasterColorRange(min: 0, max: 1)
            .rasterContrast(Double.testConstantValue())
            .rasterElevation(Double.testConstantValue())
            .rasterEmissiveStrength(Double.testConstantValue())
            .rasterFadeDuration(Double.testConstantValue())
            .rasterHueRotate(Double.testConstantValue())
            .rasterOpacity(Double.testConstantValue())
            .rasterResampling(RasterResampling.testConstantValue())
            .rasterSaturation(Double.testConstantValue())

        XCTAssertEqual(layer.filter, Exp.testConstantValue())
        XCTAssertEqual(layer.source, String.testConstantValue())
        XCTAssertEqual(layer.sourceLayer, String.testConstantValue())
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
        XCTAssertEqual(layer.minZoom, Double.testConstantValue())
        XCTAssertEqual(layer.maxZoom, Double.testConstantValue())
        XCTAssertEqual(layer.rasterArrayBand, Value.constant(String.testConstantValue()))
        XCTAssertEqual(layer.rasterBrightnessMax, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.rasterBrightnessMin, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.rasterColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.rasterColorMix, Value.constant([0, 1, 2, 3]))
        XCTAssertEqual(layer.rasterColorRange, Value.constant([0, 1]))
        XCTAssertEqual(layer.rasterContrast, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.rasterElevation, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.rasterEmissiveStrength, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.rasterFadeDuration, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.rasterHueRotate, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.rasterOpacity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.rasterResampling, Value.constant(RasterResampling.testConstantValue()))
        XCTAssertEqual(layer.rasterSaturation, Value.constant(Double.testConstantValue()))
    }
}

// End of generated file
