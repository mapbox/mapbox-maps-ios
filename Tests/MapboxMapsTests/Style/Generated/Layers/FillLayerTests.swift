// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class FillLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = FillLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.fill)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = FillLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode FillLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode FillLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(FillLayer.self, from: validData)
            XCTAssertEqual(decodedLayer.id, "test-id")
            XCTAssertEqual(decodedLayer.type, LayerType.fill)
            XCTAssert(decodedLayer.source == "source")
            XCTAssertEqual(decodedLayer.minZoom, 10.0)
            XCTAssertEqual(decodedLayer.maxZoom, 20.0)
            XCTAssertEqual(layer.slot, Slot.testConstantValue())
        } catch {
            XCTFail("Failed to decode FillLayer")
        }
    }

    func testEncodingAndDecodingOfLayoutProperties() {
        var layer = FillLayer(id: "test-id", source: "source")
        layer.visibility = .constant(.visible)
        layer.fillConstructBridgeGuardRail = Value<Bool>.testConstantValue()
        layer.fillElevationReference = Value<FillElevationReference>.testConstantValue()
        layer.fillSortKey = Value<Double>.testConstantValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode FillLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode FillLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(FillLayer.self, from: validData)
            XCTAssert(decodedLayer.visibility == .constant(.visible))
            XCTAssertEqual(layer.fillConstructBridgeGuardRail, Value<Bool>.testConstantValue())
            XCTAssertEqual(layer.fillElevationReference, Value<FillElevationReference>.testConstantValue())
            XCTAssertEqual(layer.fillSortKey, Value<Double>.testConstantValue())
        } catch {
            XCTFail("Failed to decode FillLayer")
        }
    }

    func testEncodingAndDecodingOfPaintProperties() {
       var layer = FillLayer(id: "test-id", source: "source")
       layer.fillAntialias = Value<Bool>.testConstantValue()
       layer.fillBridgeGuardRailColor = Value<StyleColor>.testConstantValue()
       layer.fillBridgeGuardRailColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillBridgeGuardRailColorUseTheme = .none
       layer.fillColor = Value<StyleColor>.testConstantValue()
       layer.fillColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillColorUseTheme = .none
       layer.fillEmissiveStrength = Value<Double>.testConstantValue()
       layer.fillEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillOpacity = Value<Double>.testConstantValue()
       layer.fillOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillOutlineColor = Value<StyleColor>.testConstantValue()
       layer.fillOutlineColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillOutlineColorUseTheme = .none
       layer.fillPattern = Value<ResolvedImage>.testConstantValue()
       layer.fillTranslate = Value<[Double]>.testConstantValue()
       layer.fillTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillTranslateAnchor = Value<FillTranslateAnchor>.testConstantValue()
       layer.fillTunnelStructureColor = Value<StyleColor>.testConstantValue()
       layer.fillTunnelStructureColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillTunnelStructureColorUseTheme = .none
       layer.fillZOffset = Value<Double>.testConstantValue()
       layer.fillZOffsetTransition = StyleTransition(duration: 10.0, delay: 10.0)

       var data: Data?
       do {
           data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode FillLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode FillLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(FillLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
           XCTAssertEqual(layer.fillAntialias, Value<Bool>.testConstantValue())
           XCTAssertEqual(layer.fillBridgeGuardRailColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.fillColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.fillEmissiveStrength, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.fillOpacity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.fillOutlineColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.fillPattern, Value<ResolvedImage>.testConstantValue())
           XCTAssertEqual(layer.fillTranslate, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.fillTranslateAnchor, Value<FillTranslateAnchor>.testConstantValue())
           XCTAssertEqual(layer.fillTunnelStructureColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.fillZOffset, Value<Double>.testConstantValue())
       } catch {
           XCTFail("Failed to decode FillLayer")
       }
    }

    func testSetPropertyValueWithFunction() {
        let layer = FillLayer(id: "test-id", source: "source")
            .filter(Exp.testConstantValue())
            .source(String.testConstantValue())
            .sourceLayer(String.testConstantValue())
            .slot(Slot.testConstantValue())
            .minZoom(Double.testConstantValue())
            .maxZoom(Double.testConstantValue())
            .fillConstructBridgeGuardRail(Bool.testConstantValue())
            .fillElevationReference(FillElevationReference.testConstantValue())
            .fillSortKey(Double.testConstantValue())
            .fillAntialias(Bool.testConstantValue())
            .fillBridgeGuardRailColor(StyleColor.testConstantValue())
            .fillColor(StyleColor.testConstantValue())
            .fillEmissiveStrength(Double.testConstantValue())
            .fillOpacity(Double.testConstantValue())
            .fillOutlineColor(StyleColor.testConstantValue())
            .fillPattern(String.testConstantValue())
            .fillTranslate(x: 0, y: 1)
            .fillTranslateAnchor(FillTranslateAnchor.testConstantValue())
            .fillTunnelStructureColor(StyleColor.testConstantValue())
            .fillZOffset(Double.testConstantValue())

        XCTAssertEqual(layer.filter, Exp.testConstantValue())
        XCTAssertEqual(layer.source, String.testConstantValue())
        XCTAssertEqual(layer.sourceLayer, String.testConstantValue())
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
        XCTAssertEqual(layer.minZoom, Double.testConstantValue())
        XCTAssertEqual(layer.maxZoom, Double.testConstantValue())
        XCTAssertEqual(layer.fillConstructBridgeGuardRail, Value.constant(Bool.testConstantValue()))
        XCTAssertEqual(layer.fillElevationReference, Value.constant(FillElevationReference.testConstantValue()))
        XCTAssertEqual(layer.fillSortKey, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.fillAntialias, Value.constant(Bool.testConstantValue()))
        XCTAssertEqual(layer.fillBridgeGuardRailColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.fillColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.fillEmissiveStrength, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.fillOpacity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.fillOutlineColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.fillPattern, Value<ResolvedImage>.constant(.name(String.testConstantValue())))
        XCTAssertEqual(layer.fillTranslate, Value.constant([0, 1]))
        XCTAssertEqual(layer.fillTranslateAnchor, Value.constant(FillTranslateAnchor.testConstantValue()))
        XCTAssertEqual(layer.fillTunnelStructureColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.fillZOffset, Value.constant(Double.testConstantValue()))
    }
}

// End of generated file
