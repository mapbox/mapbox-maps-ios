// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class BackgroundLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = BackgroundLayer(id: "test-id")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.background)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = BackgroundLayer(id: "test-id")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode BackgroundLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode BackgroundLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(BackgroundLayer.self, from: validData)
            XCTAssertEqual(decodedLayer.id, "test-id")
            XCTAssertEqual(decodedLayer.type, LayerType.background)
            XCTAssertEqual(decodedLayer.minZoom, 10.0)
            XCTAssertEqual(decodedLayer.maxZoom, 20.0)
            XCTAssertEqual(layer.slot, Slot.testConstantValue())
        } catch {
            XCTFail("Failed to decode BackgroundLayer")
        }
    }

    func testEncodingAndDecodingOfLayoutProperties() {
        var layer = BackgroundLayer(id: "test-id")
        layer.visibility = .constant(.visible)

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode BackgroundLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode BackgroundLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(BackgroundLayer.self, from: validData)
            XCTAssert(decodedLayer.visibility == .constant(.visible))
        } catch {
            XCTFail("Failed to decode BackgroundLayer")
        }
    }

    func testEncodingAndDecodingOfPaintProperties() {
       var layer = BackgroundLayer(id: "test-id")
       layer.backgroundColor = Value<StyleColor>.testConstantValue()
       layer.backgroundColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.backgroundEmissiveStrength = Value<Double>.testConstantValue()
       layer.backgroundEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.backgroundOpacity = Value<Double>.testConstantValue()
       layer.backgroundOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.backgroundPattern = Value<ResolvedImage>.testConstantValue()

       var data: Data?
       do {
           data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode BackgroundLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode BackgroundLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(BackgroundLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
           XCTAssertEqual(layer.backgroundColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.backgroundEmissiveStrength, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.backgroundOpacity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.backgroundPattern, Value<ResolvedImage>.testConstantValue())
       } catch {
           XCTFail("Failed to decode BackgroundLayer")
       }
    }

    func testSetPropertyValueWithFunction() {
        let layer = BackgroundLayer(id: "test-id")
            .slot(Slot.testConstantValue())
            .minZoom(Double.testConstantValue())
            .maxZoom(Double.testConstantValue())
            .backgroundColor(StyleColor.testConstantValue())
            .backgroundEmissiveStrength(Double.testConstantValue())
            .backgroundOpacity(Double.testConstantValue())
            .backgroundPattern(String.testConstantValue())

        XCTAssertEqual(layer.slot, Slot.testConstantValue())
        XCTAssertEqual(layer.minZoom, Double.testConstantValue())
        XCTAssertEqual(layer.maxZoom, Double.testConstantValue())
        XCTAssertEqual(layer.backgroundColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.backgroundEmissiveStrength, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.backgroundOpacity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.backgroundPattern, Value<ResolvedImage>.constant(.name(String.testConstantValue())))
    }
}

// End of generated file
