// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class HeatmapLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = HeatmapLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.heatmap)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = HeatmapLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode HeatmapLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode HeatmapLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(HeatmapLayer.self, from: validData)
            XCTAssertEqual(decodedLayer.id, "test-id")
            XCTAssertEqual(decodedLayer.type, LayerType.heatmap)
            XCTAssert(decodedLayer.source == "source")
            XCTAssertEqual(decodedLayer.minZoom, 10.0)
            XCTAssertEqual(decodedLayer.maxZoom, 20.0)
            XCTAssertEqual(layer.slot, Slot.testConstantValue())
        } catch {
            XCTFail("Failed to decode HeatmapLayer")
        }
    }

    func testEncodingAndDecodingOfLayoutProperties() {
        var layer = HeatmapLayer(id: "test-id", source: "source")
        layer.visibility = .constant(.visible)

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode HeatmapLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode HeatmapLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(HeatmapLayer.self, from: validData)
            XCTAssert(decodedLayer.visibility == .constant(.visible))
        } catch {
            XCTFail("Failed to decode HeatmapLayer")
        }
    }

    func testEncodingAndDecodingOfPaintProperties() {
       var layer = HeatmapLayer(id: "test-id", source: "source")
       layer.heatmapColor = Value<StyleColor>.testConstantValue()
       layer.heatmapIntensity = Value<Double>.testConstantValue()
       layer.heatmapIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.heatmapOpacity = Value<Double>.testConstantValue()
       layer.heatmapOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.heatmapRadius = Value<Double>.testConstantValue()
       layer.heatmapRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.heatmapWeight = Value<Double>.testConstantValue()

       var data: Data?
       do {
           data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode HeatmapLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode HeatmapLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(HeatmapLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
           XCTAssertEqual(layer.heatmapColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.heatmapIntensity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.heatmapOpacity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.heatmapRadius, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.heatmapWeight, Value<Double>.testConstantValue())
       } catch {
           XCTFail("Failed to decode HeatmapLayer")
       }
    }

    func testSetPropertyValueWithFunction() {
        let layer = HeatmapLayer(id: "test-id", source: "source")
            .filter(Exp.testConstantValue())
            .source(String.testConstantValue())
            .sourceLayer(String.testConstantValue())
            .slot(Slot.testConstantValue())
            .minZoom(Double.testConstantValue())
            .maxZoom(Double.testConstantValue())
            .heatmapColor(StyleColor.testConstantValue())
            .heatmapIntensity(Double.testConstantValue())
            .heatmapOpacity(Double.testConstantValue())
            .heatmapRadius(Double.testConstantValue())
            .heatmapWeight(Double.testConstantValue())

        XCTAssertEqual(layer.filter, Exp.testConstantValue())
        XCTAssertEqual(layer.source, String.testConstantValue())
        XCTAssertEqual(layer.sourceLayer, String.testConstantValue())
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
        XCTAssertEqual(layer.minZoom, Double.testConstantValue())
        XCTAssertEqual(layer.maxZoom, Double.testConstantValue())
        XCTAssertEqual(layer.heatmapColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.heatmapIntensity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.heatmapOpacity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.heatmapRadius, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.heatmapWeight, Value.constant(Double.testConstantValue()))
    }
}

// End of generated file
