// This file is generated
import XCTest
@testable import MapboxMaps

final class LineLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = LineLayer(id: "test-id")
        layer.source = "some-source"
        layer.sourceLayer = nil
        layer.minZoom = 10.0
        layer.maxZoom = 20.0

        XCTAssert(layer.id == "test-id")
        XCTAssert(layer.type == LayerType.line)
        XCTAssert(layer.filter == nil)
        XCTAssert(layer.source == "some-source")
        XCTAssertNil(layer.sourceLayer)
        XCTAssert(layer.minZoom == 10.0)
        XCTAssert(layer.maxZoom == 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = LineLayer(id: "test-id")
        layer.source = "some-source"
        layer.sourceLayer = nil
        layer.minZoom = 10.0
        layer.maxZoom = 20.0

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
            XCTAssert(decodedLayer.id == "test-id")
            XCTAssert(decodedLayer.type == LayerType.line)
            XCTAssert(decodedLayer.filter == nil)
            XCTAssert(decodedLayer.source == "some-source")
            XCTAssertNil(decodedLayer.sourceLayer)
            XCTAssert(decodedLayer.minZoom == 10.0)
            XCTAssert(decodedLayer.maxZoom == 20.0)
        } catch {
            XCTFail("Failed to decode LineLayer")
        }
    }

    func testEncodingAndDecodingOfLayoutProperties() {
        var layer = LineLayer(id: "test-id")
        layer.visibility = .constant(.visible)
        layer.lineCap = Value<LineCap>.testConstantValue()
        layer.lineJoin = Value<LineJoin>.testConstantValue()
        layer.lineMiterLimit = Value<Double>.testConstantValue()
        layer.lineRoundLimit = Value<Double>.testConstantValue()
        layer.lineSortKey = Value<Double>.testConstantValue()

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
            XCTAssert(layer.lineCap == Value<LineCap>.testConstantValue())
            XCTAssert(layer.lineJoin == Value<LineJoin>.testConstantValue())
            XCTAssert(layer.lineMiterLimit == Value<Double>.testConstantValue())
            XCTAssert(layer.lineRoundLimit == Value<Double>.testConstantValue())
            XCTAssert(layer.lineSortKey == Value<Double>.testConstantValue())
        } catch {
            XCTFail("Failed to decode LineLayer")
        }
    }

    func testEncodingAndDecodingOfPaintProperties() {
       var layer = LineLayer(id: "test-id")
       layer.lineBlur = Value<Double>.testConstantValue()
       layer.lineBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineColor = Value<StyleColor>.testConstantValue()
       layer.lineColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineDasharray = Value<[Double]>.testConstantValue()
       layer.lineDasharrayTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineGapWidth = Value<Double>.testConstantValue()
       layer.lineGapWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineGradient = Value<StyleColor>.testConstantValue()
       layer.lineOffset = Value<Double>.testConstantValue()
       layer.lineOffsetTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineOpacity = Value<Double>.testConstantValue()
       layer.lineOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.linePattern = Value<ResolvedImage>.testConstantValue()
       layer.linePatternTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineTranslate = Value<[Double]>.testConstantValue()
       layer.lineTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.lineTranslateAnchor = Value<LineTranslateAnchor>.testConstantValue()
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
           XCTAssert(layer.lineBlur == Value<Double>.testConstantValue())
           XCTAssert(layer.lineColor == Value<StyleColor>.testConstantValue())
           XCTAssert(layer.lineDasharray == Value<[Double]>.testConstantValue())
           XCTAssert(layer.lineGapWidth == Value<Double>.testConstantValue())
           XCTAssert(layer.lineGradient == Value<StyleColor>.testConstantValue())
           XCTAssert(layer.lineOffset == Value<Double>.testConstantValue())
           XCTAssert(layer.lineOpacity == Value<Double>.testConstantValue())
           XCTAssert(layer.linePattern == Value<ResolvedImage>.testConstantValue())
           XCTAssert(layer.lineTranslate == Value<[Double]>.testConstantValue())
           XCTAssert(layer.lineTranslateAnchor == Value<LineTranslateAnchor>.testConstantValue())
           XCTAssert(layer.lineTrimOffset == Value<[Double]>.testConstantValue())
           XCTAssert(layer.lineWidth == Value<Double>.testConstantValue())
       } catch {
           XCTFail("Failed to decode LineLayer")
       }
    }
}

// End of generated file
