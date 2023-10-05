// This file is generated
import XCTest
@testable import MapboxMaps

final class CircleLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = CircleLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.circle)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = CircleLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode CircleLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode CircleLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(CircleLayer.self, from: validData)
            XCTAssertEqual(decodedLayer.id, "test-id")
            XCTAssertEqual(decodedLayer.type, LayerType.circle)
            XCTAssert(decodedLayer.source == "source")
            XCTAssertEqual(decodedLayer.minZoom, 10.0)
            XCTAssertEqual(decodedLayer.maxZoom, 20.0)
        } catch {
            XCTFail("Failed to decode CircleLayer")
        }
    }

    func testEncodingAndDecodingOfLayoutProperties() {
        var layer = CircleLayer(id: "test-id", source: "source")
        layer.visibility = .constant(.visible)
        layer.circleSortKey = Value<Double>.testConstantValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode CircleLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode CircleLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(CircleLayer.self, from: validData)
            XCTAssert(decodedLayer.visibility == .constant(.visible))
            XCTAssertEqual(layer.circleSortKey, Value<Double>.testConstantValue())
        } catch {
            XCTFail("Failed to decode CircleLayer")
        }
    }

    func testEncodingAndDecodingOfPaintProperties() {
       var layer = CircleLayer(id: "test-id", source: "source")
       layer.circleBlur = Value<Double>.testConstantValue()
       layer.circleBlurTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circleColor = Value<StyleColor>.testConstantValue()
       layer.circleColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circleEmissiveStrength = Value<Double>.testConstantValue()
       layer.circleEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circleOpacity = Value<Double>.testConstantValue()
       layer.circleOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circlePitchAlignment = Value<CirclePitchAlignment>.testConstantValue()
       layer.circlePitchScale = Value<CirclePitchScale>.testConstantValue()
       layer.circleRadius = Value<Double>.testConstantValue()
       layer.circleRadiusTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circleStrokeColor = Value<StyleColor>.testConstantValue()
       layer.circleStrokeColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circleStrokeOpacity = Value<Double>.testConstantValue()
       layer.circleStrokeOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circleStrokeWidth = Value<Double>.testConstantValue()
       layer.circleStrokeWidthTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circleTranslate = Value<[Double]>.testConstantValue()
       layer.circleTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.circleTranslateAnchor = Value<CircleTranslateAnchor>.testConstantValue()

       var data: Data?
       do {
           data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode CircleLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode CircleLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(CircleLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
           XCTAssertEqual(layer.circleBlur, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.circleColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.circleEmissiveStrength, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.circleOpacity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.circlePitchAlignment, Value<CirclePitchAlignment>.testConstantValue())
           XCTAssertEqual(layer.circlePitchScale, Value<CirclePitchScale>.testConstantValue())
           XCTAssertEqual(layer.circleRadius, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.circleStrokeColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.circleStrokeOpacity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.circleStrokeWidth, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.circleTranslate, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.circleTranslateAnchor, Value<CircleTranslateAnchor>.testConstantValue())
       } catch {
           XCTFail("Failed to decode CircleLayer")
       }
    }
}

// End of generated file
