// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class LineLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = LineLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.line)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = LineLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode LineLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode LineLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(LineLayer.self, from: validData)
            XCTAssertEqual(decodedLayer.id, "test-id")
            XCTAssertEqual(decodedLayer.type, LayerType.line)
            XCTAssert(decodedLayer.source == "source")
            XCTAssertEqual(decodedLayer.minZoom, 10.0)
            XCTAssertEqual(decodedLayer.maxZoom, 20.0)
            XCTAssertEqual(layer.slot, Slot.testConstantValue())
        } catch {
            XCTFail("Failed to decode LineLayer")
        }
    }

    func testEncodingAndDecodingOfLayoutProperties() {
        var layer = LineLayer(id: "test-id", source: "source")
        layer.visibility = .constant(.visible)
        layer.lineCap = Value<LineCap>.testConstantValue()
        layer.lineCrossSlope = Value<Double>.testConstantValue()
        layer.lineElevationReference = Value<LineElevationReference>.testConstantValue()
        layer.lineJoin = Value<LineJoin>.testConstantValue()
        layer.lineMiterLimit = Value<Double>.testConstantValue()
        layer.lineRoundLimit = Value<Double>.testConstantValue()
        layer.lineSortKey = Value<Double>.testConstantValue()
        layer.lineWidthUnit = Value<LineWidthUnit>.testConstantValue()
        layer.lineZOffset = Value<Double>.testConstantValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode LineLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode LineLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(LineLayer.self, from: validData)
            XCTAssert(decodedLayer.visibility == .constant(.visible))
            XCTAssertEqual(layer.lineCap, Value<LineCap>.testConstantValue())
            XCTAssertEqual(layer.lineCrossSlope, Value<Double>.testConstantValue())
            XCTAssertEqual(layer.lineElevationReference, Value<LineElevationReference>.testConstantValue())
            XCTAssertEqual(layer.lineJoin, Value<LineJoin>.testConstantValue())
            XCTAssertEqual(layer.lineMiterLimit, Value<Double>.testConstantValue())
            XCTAssertEqual(layer.lineRoundLimit, Value<Double>.testConstantValue())
            XCTAssertEqual(layer.lineSortKey, Value<Double>.testConstantValue())
            XCTAssertEqual(layer.lineWidthUnit, Value<LineWidthUnit>.testConstantValue())
            XCTAssertEqual(layer.lineZOffset, Value<Double>.testConstantValue())
        } catch {
            XCTFail("Failed to decode LineLayer")
        }
    }

    func testEncodingAndDecodingOfPaintProperties() {
       var layer = LineLayer(id: "test-id", source: "source")
       layer.lineBlur = Value<Double>.testConstantValue()
       layer.lineBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineBorderColor = Value<StyleColor>.testConstantValue()
       layer.lineBorderColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineBorderColorUseTheme = .none
       layer.lineBorderWidth = Value<Double>.testConstantValue()
       layer.lineBorderWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineColor = Value<StyleColor>.testConstantValue()
       layer.lineColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineColorUseTheme = .none
       layer.lineDasharray = Value<[Double]>.testConstantValue()
       layer.lineDepthOcclusionFactor = Value<Double>.testConstantValue()
       layer.lineDepthOcclusionFactorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineEmissiveStrength = Value<Double>.testConstantValue()
       layer.lineEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineGapWidth = Value<Double>.testConstantValue()
       layer.lineGapWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineGradient = Value<StyleColor>.testConstantValue()
       layer.lineGradientUseTheme = .none
       layer.lineOcclusionOpacity = Value<Double>.testConstantValue()
       layer.lineOcclusionOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineOffset = Value<Double>.testConstantValue()
       layer.lineOffsetTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineOpacity = Value<Double>.testConstantValue()
       layer.lineOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.linePattern = Value<ResolvedImage>.testConstantValue()
       layer.lineTranslate = Value<[Double]>.testConstantValue()
       layer.lineTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineTranslateAnchor = Value<LineTranslateAnchor>.testConstantValue()
       layer.lineTrimColor = Value<StyleColor>.testConstantValue()
       layer.lineTrimColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineTrimColorUseTheme = .none
       layer.lineTrimFadeRange = Value<[Double]>.testConstantValue()
       layer.lineTrimOffset = Value<[Double]>.testConstantValue()
       layer.lineWidth = Value<Double>.testConstantValue()
       layer.lineWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)

       var data: Data?
       do {
           data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode LineLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode LineLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(LineLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
           XCTAssertEqual(layer.lineBlur, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.lineBorderColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.lineBorderWidth, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.lineColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.lineDasharray, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.lineDepthOcclusionFactor, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.lineEmissiveStrength, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.lineGapWidth, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.lineGradient, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.lineOcclusionOpacity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.lineOffset, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.lineOpacity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.linePattern, Value<ResolvedImage>.testConstantValue())
           XCTAssertEqual(layer.lineTranslate, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.lineTranslateAnchor, Value<LineTranslateAnchor>.testConstantValue())
           XCTAssertEqual(layer.lineTrimColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.lineTrimFadeRange, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.lineTrimOffset, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.lineWidth, Value<Double>.testConstantValue())
       } catch {
           XCTFail("Failed to decode LineLayer")
       }
    }

    func testSetPropertyValueWithFunction() {
        let layer = LineLayer(id: "test-id", source: "source")
            .filter(Exp.testConstantValue())
            .source(String.testConstantValue())
            .sourceLayer(String.testConstantValue())
            .slot(Slot.testConstantValue())
            .minZoom(Double.testConstantValue())
            .maxZoom(Double.testConstantValue())
            .lineCap(LineCap.testConstantValue())
            .lineCrossSlope(Double.testConstantValue())
            .lineElevationReference(LineElevationReference.testConstantValue())
            .lineJoin(LineJoin.testConstantValue())
            .lineMiterLimit(Double.testConstantValue())
            .lineRoundLimit(Double.testConstantValue())
            .lineSortKey(Double.testConstantValue())
            .lineWidthUnit(LineWidthUnit.testConstantValue())
            .lineZOffset(Double.testConstantValue())
            .lineBlur(Double.testConstantValue())
            .lineBorderColor(StyleColor.testConstantValue())
            .lineBorderWidth(Double.testConstantValue())
            .lineColor(StyleColor.testConstantValue())
            .lineDashArray([Double].testConstantValue())
            .lineDepthOcclusionFactor(Double.testConstantValue())
            .lineEmissiveStrength(Double.testConstantValue())
            .lineGapWidth(Double.testConstantValue())
            .lineGradient(StyleColor.testConstantValue())
            .lineOcclusionOpacity(Double.testConstantValue())
            .lineOffset(Double.testConstantValue())
            .lineOpacity(Double.testConstantValue())
            .linePattern(String.testConstantValue())
            .lineTranslate(x: 0, y: 1)
            .lineTranslateAnchor(LineTranslateAnchor.testConstantValue())
            .lineTrimColor(StyleColor.testConstantValue())
            .lineTrimFadeRange(start: 0, end: 1)
            .lineTrimOffset(start: 0, end: 1)
            .lineWidth(Double.testConstantValue())

        XCTAssertEqual(layer.filter, Exp.testConstantValue())
        XCTAssertEqual(layer.source, String.testConstantValue())
        XCTAssertEqual(layer.sourceLayer, String.testConstantValue())
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
        XCTAssertEqual(layer.minZoom, Double.testConstantValue())
        XCTAssertEqual(layer.maxZoom, Double.testConstantValue())
        XCTAssertEqual(layer.lineCap, Value.constant(LineCap.testConstantValue()))
        XCTAssertEqual(layer.lineCrossSlope, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.lineElevationReference, Value.constant(LineElevationReference.testConstantValue()))
        XCTAssertEqual(layer.lineJoin, Value.constant(LineJoin.testConstantValue()))
        XCTAssertEqual(layer.lineMiterLimit, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.lineRoundLimit, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.lineSortKey, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.lineWidthUnit, Value.constant(LineWidthUnit.testConstantValue()))
        XCTAssertEqual(layer.lineZOffset, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.lineBlur, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.lineBorderColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.lineBorderWidth, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.lineColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.lineDasharray, Value.constant([Double].testConstantValue()))
        XCTAssertEqual(layer.lineDepthOcclusionFactor, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.lineEmissiveStrength, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.lineGapWidth, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.lineGradient, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.lineOcclusionOpacity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.lineOffset, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.lineOpacity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(layer.linePattern, Value<ResolvedImage>.constant(.name(String.testConstantValue())))
        XCTAssertEqual(layer.lineTranslate, Value.constant([0, 1]))
        XCTAssertEqual(layer.lineTranslateAnchor, Value.constant(LineTranslateAnchor.testConstantValue()))
        XCTAssertEqual(layer.lineTrimColor, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(layer.lineTrimFadeRange, Value.constant([0, 1]))
        XCTAssertEqual(layer.lineTrimOffset, Value.constant([0, 1]))
        XCTAssertEqual(layer.lineWidth, Value.constant(Double.testConstantValue()))
    }
}

// End of generated file
